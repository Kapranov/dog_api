defmodule DogAPI.CodeAntiPatterns do
  @moduledoc """
  Anti-patterns describe common mistakes or indicators of problems
  in code. They are also known as "code smells".

  `https://hexdocs.pm/elixir/what-anti-patterns.html`
  `https://hexdocs.pm/elixir/code-anti-patterns.html`
  """

  @five_min_in_seconds 60 * 5

  @doc """
  Returns the Unix timestamp of 5 minutes from the current time
  then get the current time, convert it to a Unix timestamp and
  add five minutes in seconds.
  """
  def run, do: unix_five_min_from_now()

  defp unix_five_min_from_now do
    now = DateTime.utc_now()
    unix_now = DateTime.to_unix(now, :second)
    unix_now + @five_min_in_seconds
  end
end

defmodule DogAPI.Calculator do
  @moduledoc """
  Calculator that performs basic arithmetic operations.

  This code is unnecessarily organized in a GenServer process.

  ## Example.

      iex> {:ok, pid} = GenServer.start_link(DogAPI.Calculator, :init)
      {:ok, pid}
      iex> DogAPI.Calculator.add(1, 5, pid)
      6
      iex> DogAPI.Calculator.subtract(2, 3, pid)
      -1

  """

  use GenServer

  def add(a, b, pid) do
    GenServer.call(pid, {:add, a, b})
  end

  def subtract(a, b, pid) do
    GenServer.call(pid, {:subtract, a, b})
  end

  @impl GenServer
  def init(args), do: {:ok, args}

  @impl GenServer
  def handle_call({:add, a, b}, _from, state) do
    {:reply, a + b, state}
  end

  def handle_call({:subtract, a, b}, _from, state) do
    {:reply, a - b, state}
  end
end
