defmodule DogAPI.LogConsumer do
  @moduledoc """
  """

  use GenStage

  @doc """

  ## Examples.

      iex> {:ok, customer} = DogAPI.LogConsumer.start_link
      customer

      iex> GenStage.sync_subscribe(customer, to: error, max_demand: 10)
      iex> GenStage.sync_subscribe(customer, to: info,  max_demand: 10)
      iex> GenStage.sync_subscribe(customer, to: warn,  max_demand: 10)

  """
  def start_link, do: GenStage.start_link(name(), :ok, name: name())

  def init(:ok), do: {:consumer, nil}

  def handle_events(logs, _from, state) do
    IO.puts("Loaded: #{length(logs)} logs")
    {:noreply, [], state}
  end

  defp name(), do: __MODULE__
end
