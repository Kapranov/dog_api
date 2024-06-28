defmodule DogAPI.EthSync.Producer do
  @moduledoc false

  alias DogAPI.EthSync.Infura

  use GenStage

  @doc """

  ## Examples.

      iex> {:ok, producer} = DogAPI.EthSync.Producer.start_link
      {:ok, producer}

  """
  def start_link, do: GenStage.start_link(name(), :ok, name: name())

  def init(:ok), do: {:producer, 1}

  def handle_demand(demand, next_block) when demand > 0 do
    IO.puts("Demanding #{demand}")

    blocks =
      next_block..(next_block - 1 + demand)
      |> Enum.map(fn n ->
        IO.puts("Fetching block #{n}")
        Infura.get_block(n)
      end)

    {:noreply, blocks, next_block + length(blocks)}
  end

  defp name, do: __MODULE__
end
