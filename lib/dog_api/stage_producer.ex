defmodule DogAPI.StageProducer do
  @moduledoc """
  """

  use GenStage

  require Logger

  def start_link(num), do: GenStage.start_link(name(), num, name: name())

  def init(num) do
    Logger.info("Producer an init kick-off number is #{num}")
    {:producer, num}
  end

  @doc """
  a `producer` will only ever need `handle_demand`.
  """
  def handle_demand(demand, state) when demand > 0 do
    events = Enum.to_list(state..state+demand-1)
    {:noreply, events, state + demand}
  end

  defp name, do: __MODULE__
end
