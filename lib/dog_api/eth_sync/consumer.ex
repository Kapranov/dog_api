defmodule DogAPI.EthSync.Consumer do
  @moduledoc false

  use GenStage

  @doc """

  ## Examples.

      iex> {:ok, producer} = DogAPI.EthSync.Producer.start_link
      {:ok, producer}
      iex> {:ok, consumer} = DogAPI.EthSync.Consumer.start_link
      {:ok, consumer}
      iex> GenStage.sync_subscribe(consumer, to: producer, max_demand: 3)
      Demanding 3
      Fetching block 1

  """
  def start_link, do: GenStage.start_link(name(), :ok, name: name())

  def init(:ok), do: {:consumer, nil}

  def handle_events(blocks, _from, state) do
    blocks
    |> Enum.each(fn
      {:ok, %{"number" => n}} ->
        IO.puts("Received block #{n}")
        :timer.sleep(1_000)
    end)

    {:noreply, [], state}
  end

  defp name, do: __MODULE__
end
