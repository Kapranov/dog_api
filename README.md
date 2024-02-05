# DogApi

**TODO: Add description**

```elixir
@doc"""
Returns a map containing all files and their contents from the compressed tar archive.
"""
def extract_tar_from_binary(binary) do
  with {:ok, files} <- :erl_tar.extract({:binary, binary}, [:memory, :compressed]) do
    files
    |> Enum.map(fn {filename, content} -> {to_string(filename), content} end)
    |> Map.new
  end
end
```

## Processing very large text files in Elixir

Last weekend, while taking my chance at `the.one.billion.row.challenge.jpg`
using Elixir, I learned quite a few things. I want to share all of them
with you but, maybe that’s best suited for a talk. So, in this post I’ll
focus on just one of them: The performance of reading a huge text file
with millions of records.

How did I get here?

The overall structure of my solution for 1BRC - `the.one.billion.row.challenge.jpg`
is this:

```elixir
path
|> File.stream!()                                     # Streams the lines of the file
|> Stream.chunk_every(@chunk_size)                    # Creates chunks of lines for processing
|> Enum.map(&Task.async(fn -> process_chunk(&1) end)) # Creates a task for each chunk
|> Enum.map(&Task.await(&1))                          # Waits for each task to finish
|> Enum.reduce(%{}, &summarize_chunk_results/2)       # Merges the results of all tasks
|> Enum.map(&stats/1)                                 # Calculates the stats for each weather station
```

For the sake of this post, let’s say that the value of `@chunk_size` is
`100_000`. I iterated over my original (and very naive) solution several
times to optimize for performance, but my results were very far from the
results I had already seen in Javaland (around 8 secs at the time).

Then I profiled my code using fprof, erlgrind and qcachegrind (see basic
instructions here -
`https://blog.equanimity.nl/blog/2013/04/24/fprof-kcachegrind/`) and,
based on the analysis of the results, I managed to make some quite nice
improvements. I repeated this process a few times, but at the end I was
annoyed to see that a lot of the time was spent on Stream-related operations.

I had the suspicion that the sole reading of the file was consuming a lot
of time, and indeed it was! Here’s a treemap - `treemap.jpg` representing
the distribution of the execution times when I fed my program with 10 million
rows.

The big rectangle at the right is composed of functions from the `Enumerable.Stream`
module and a call to `Enum.map/2`.

Let’s think about it: When we call `Enum.map/2` (line 4), in every iteration
it asks the stream generated by `Stream.chunk/2` for a new chunk of lines.
Since streams are lazily evaluated, this stream asks the stream generated by
`File.stream!/1` for enough lines to fill a chunk (or the very last lines of
the file, when there are no more). This is why `Enum.map/2` seems to take a
lot of the total time.

But… reading the file takes almost the half of the overall time!
This is no good! Not at all!

After walking in circles for a while in my home office, I typed a small
program just to confirm my findings and to use it as a benchmark for
different approaches to reading the file.

```elixir
path
|> File.stream!()
|> Stream.chunk_every(@chunk_size)
|> Enum.map(fn _ -> :ok end)
```

The idea was to measure how much time it takes just to read the file and
create big chunks of lines from it.

Oh! before we delve into the results, the machine I work with is a MacBook
Pro with an Apple M1 Max chip (10 cores) and 32 Gb of memory.

So, here we go…

```
| # records  | size   | time (sec) |
| ---------- | ------ |----------- |
| 1 M        | 13 Mb  | 0.19       |
| 10 M       | 132 Mb | 1.58       |
| 100 M      | 1.3 Gb | 15.47      |
| 1 B        | 13 Gb  | 156.39     |
```

This is nuts! don’t you think? With those times I could never ever be able
to compete with the Java solutions! Just to read a 1 billion records file,
I should expect to spend about 156 seconds! I must confess I got very
disappointed and started feeling blue at this time. What could I do?

Then I thought: how much does it take to read the whole file without streaming?
It turned out that for the 1 billion records file (13 Gb) the answer is….

```elixir
iex(1)> Benchmark.measure(fn -> File.read!("measurements_1_000_000_000.txt") end)
4.87 secs
```

Sometimes it takes longer, but anyway, it’s around 5 seconds! So, how come
it takes around 156 seconds to read it in an streaming way and create
`10_000` chunks? (`1_000_000_000 records / 100_000 lines`).

Then I started thinking about different ways to read the file and slurp
lines from it. At the end I found out other 4 different ways to do it
(with the help of Elixir Forum). I’m gonna present you each one of them
and after that I’ll show you my benchmarks.

Opt 1: Just use File.stream! to stream line by line

This is the original approach. Let’s give it a codename: `:fstream`.

Opt 2: Read whole file and stream lines form it

This means basically to create a stream of lines given the huge binary
returned from `File.read!/1`. It took me a while to get this working,
since I had never created a stream. The codename for this approach is
`:whole_read`.

```elixir
def lines_stream(path, :whole_read) do
  path |> File.read!() |> line_stream()
end

def line_stream(b) when is_binary(b) do
  Stream.unfold(b, fn b ->
    case String.split(b, "\n", parts: 2) do
      [line, rest] ->
        {line, rest}

      [""] ->
        nil
    end
  end)
end
```

Opt 3: Read whole file, create an IO dev from it, then stream lines from it

In this approach, after reading the whole file, we create an Erlang IO
device using the whole binary as it’s source, and then we create a line
stream from it. I found this approach in forums. Codename is `:whole_read_string_io`.

```elixir
def lines_stream(path, :whole_read_string_io) do
  {:ok, io_dev} = path |> File.read!() |> StringIO.open()
  IO.binstream(io_dev, :line)
end
```

Opt 4: Create a stream of large binary chunks, from this create a stream
that produces lines

So, what if we read the file in large chunks (binary mode) and from this
we slurp lines through a new stream? This basically reads blocks of
`500_000` bytes each time, from each one of them, it creates a list of
lines which get fed through a Stream of lines. Codename is
`:chunked_bin_read`.

```elixir
def lines_stream(path, :chunked_bin_read) do
  path |> File.stream!([], 500_000) |> line_stream_from_binary_stream()
end

def line_stream_from_binary_stream(bin_stream) do
  bin_stream
  |> Stream.transform("", fn chunk, acc ->
    [last_line | lines] =
      acc <> chunk
      |> String.split("\n")
      |> Enum.reverse()
    {Enum.reverse(lines), last_line} # reverse is only needed if you care about original order of the lines
  end)
end
```

Opt 5: Read the whole file, then stream it by binary chunks, then by lines

This is similar to Option 4, but instead of relying on `File.stream!/3`
we read the whole file in one step. From there we create a stream that
reads large blocks of the binary and then another stream that slurps
lines. Codename is `:whole_read_chunked_bin`.

```elixir
def lines_stream(path, :whole_read_chunked_bin) do
  path |> File.read!() |> binary_stream() |> line_stream_from_binary_stream()
end

def binary_stream(b, chunk_size \\ 500_000) when is_binary(b) do
  Stream.unfold(0, fn skip ->
    case b do
      <<_skipped::binary-size(skip), chunk::binary-size(chunk_size), _rest::binary>> ->
        {chunk, skip + chunk_size}

      <<_skipped::binary-size(skip)>> ->
        nil

      <<_skipped::binary-size(skip), chunk::binary>> ->
        {chunk, skip + byte_size(chunk)}
    end
  end)
end

def line_stream_from_binary_stream(bin_stream) do
  # defined above
end
```

Place your bets!

Long story short, these are the results I got for each approach, varying
the size of the input (up to 1 billion records):

```bash
| size  | fstream | whole_read_string_io | whole_read | chunked_bin_read | whole_read_chunked_bin |
| ----- | ------- | -------------------- | ---------- | ---------------- | ---------------------- |
| 1 M   | 0.19    | 1.12                 | 0.32       | 0.12             | 0.16                   |
| 10 M  | 1.54    | 10.90                | 2.76       | 0.87             | 1.09                   |
| 100 M | 15.28   | 110.36               | 26.97      | 8.44             | 10.61                  |
| 1 B   | 152.69  | 1154.50              | 269.84     | 85.81            | 111.95                 |
```

As you can see, `chunked_bin_read` is the solution with the best times.

What is happening with this approach is that when iterating with
`Enum.map(fn _ -> :ok end)`, each iteration asks the incoming stream for a
chunk of strings, then this stream asks the stream returned by
`File.stream!(path, [], 500_000)` for a next element, which turns out
to be a binary of `500_000` bytes, and from there we generate as many
text lines as are available. This way, with a single IO read operation
we have plenty to create a lot of lines for a single chunk.
This is called buffered reading.

Missing functionality in File.stream/3 ?

Wait, but is there an option to do this using the existing standard
library and without resorting to convoluted stream manipulation?

Unfortunately no. The documentation for `File.stream!/3` states that

```bash
The `line_or_bytes` argument configures how the file is read when streaming, by `:line` (default) or by a given number of bytes. When using the `:line` option, CRLF line breaks (`"\r\n"`) are normalized to LF (`"\n"`).
```

That is, you read by lines or by blocks of bytes. There’s nothing like
“please slurp me lines, but read from the device in a buffered way”.
Reading the implementation of `File.stream!/3` confirmed this.

If this is a missing feature or not, is something we may discuss in
the official repo, but looking back at the benchmarks I just showed
you, wouldn’t be very beneficial to have this feature? In my use case
it improved the execution time almost twice.

My final results for 1BRC

The distribution of the execution time for my final solutions
is represented in this treemap.

The big rectangle at the right edge represents the amount time spent
reading the file (around 14 %), which is still large in my opinion,
but it’s the best I could get.

You can see that there are two big rectangles at the center-top.
Those are related to the `String.split/2` and `Float.parse/1`
functions that I use to process each record. I guess there’s a more
optimal way to do it, but I haven’t found it in Erlang/Elixir, yet.

Anyway, 85 secs for just reading the lines from the file
(see the benchmarks above) is not going to take me any near
the solutions some people have written in Java (even though those
benchmarks are performed on a 64 cores machine).

Takeaways

Taking your chance at the 1BRC is a very interesting learning
experience. As simple as the challenge appears to be, it is a great
opportunity to learn from different angles: it will help you to assess
your knowledge about your chosen platform and about computing in general,
it will also help you figure out a new set of skills focusing on
optimization, and finally, it will give you a better perspective about
how different platforms compare given this specific problem.

If you don’t know how to profile Elixir programs, I very much suggest
you to learn how to. These techniques have helped me several times in
real world projects, making improvements to Archeometer, and now in
this insightful exercise.

I know very little about Erlang IO performance and subtleties related
to storage operations. It had never been an issue for me before.
I need to learn more!

And that’s all folks!

Any comments or suggestions are gladly welcomed!


### 10 Jan 2024 by Oleg G.Kapranov


[1]:  https://blog.appsignal.com/2021/10/26/how-to-use-macros-in-elixir.html
[2]:  https://hexdocs.pm/elixir/1.16.0/Macro.html
[3]:  https://github.com/edgurgel/httpoison
[4]:  https://www.thedogapi.com/
[5]:  https://developers.thecatapi.com/view-account/ylX4blBYT9FaoVd6OhvR?report=s7StySvTw
[6]:  https://documenter.getpostman.com/view/5578104/2s935hRnak#587d112a-cfbb-4817-9a84-98a606113973
[7]:  https://github.com/mgwidmann/httpoison_retry
[8]:  https://github.com/andridus/httpmock
[9]:  https://github.com/bernardolins/fake_server
[10]: https://github.com/ananthakumaran/zstream
[11]: https://github.com/fishcakez/dbg/blob/master/lib/dbg/watcher.ex
[12]: https://www.ntecs.de/posts/2024-01-29-one-billion-record-challenge-in-elixir-faster/
[13]: https://medium.com/elemental-elixir/processing-very-large-text-files-in-elixir-b631792eed59
[14]: https://github.com/gunnarmorling/1brc
[15]: https://github.com/mneumann/1brc-elixir
[16]: https://hexdocs.pm/gen_state_machine/GenStateMachine.html
[17]: https://blog.appsignal.com/2020/07/14/building-state-machines-in-elixir-with-ecto.html
[18]: https://habr.com/ru/articles/511780/
[19]: https://github.com/subvisual/fsmx
[20]: https://github.com/joaomdmoura/machinery
[21]: https://github.com/ericentin/gen_state_machine
