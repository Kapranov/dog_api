defmodule DogAPI.Benchmark do
  @moduledoc false

  @doc """
  Benchee allows you to compare the performance of different pieces of code at a glance.

  ## Example.

      iex> @separator ";"
      iex> @line_separator "\n"
      iex> @escape "\""
      iex> @lower = for n <- ?a..?z, do: << n :: utf8 >>
      iex> @upper for n <- ?A..?Z, do: << n :: utf8 >>
      iex> @numeric for n <- ?0..?9, do: << n :: utf8 >>
      iex> @symbol for n <- [?_,?-,?+,?/,?*], do: << n :: utf8 >>

      iex> DogAPI.Benchmark.run("foia-hawaii-extract.zip")

  """
  @spec run(String.t()) :: %Benchee.Suite{}
  def run(file) when is_bitstring(file) do
    ptin_csv = download(file)
    ptin_string = ptin_csv |> File.read!()
    ptin_list = ptin_csv |> File.stream!() |> Stream.map(&String.downcase(&1)) |> Stream.drop(1)
    ptin_stream = ptin_list |> Stream.map(& &1)

    Benchee.run(
      %{
        "2760k lines, 16 columns - NimbleCSV.RFC4180.parse_string/1" => fn ->
          NimbleCSV.RFC4180.parse_string(ptin_string)
        end,

        "2760k lines, 16 columns - NimbleCSV.RFC4180.parse_stream/1" => fn ->
          ptin_stream
          |> NimbleCSV.RFC4180.parse_stream()
          |> Enum.to_list()
        end,

        "2760k lines, 16 columns - NimbleCSV.RFC4180.parse_enumerable/1" => fn ->
          NimbleCSV.RFC4180.parse_enumerable(ptin_list)
        end
      }
    )
  end

  defp download(file) do
    url = 'https://www.irs.gov/pub/irs-utl/#{file}'
    headers = []
    path_to_file =
      System.tmp_dir!()
      |> Path.join(file)
      |> String.to_charlist()

    http_request_opts = [
      ssl: [
      verify: :verify_peer,
      cacerts: :public_key.cacerts_get(),
      customize_hostname_check: [
        match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
    ]]]

    {:ok, :saved_to_file} =
      :httpc.request(:get, {url, headers}, http_request_opts, [stream: path_to_file])

    {:ok, data} = :file.read_file(path_to_file)

    case :zip.unzip(data, [{:cwd, ~c'/tmp/'}]) do
      {:ok, [content]} -> content
      {:error, error} -> error
    end
  end
end
