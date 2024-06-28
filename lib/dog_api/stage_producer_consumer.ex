defmodule DogAPI.StageProducerConsumer do
  @moduledoc """
  """

  alias DogAPI.StageProducer

  use GenStage

  require Logger

  @name "StageProcessor"

  def start_link(num) do
    GenStage.start_link(name(), num, name: String.to_atom(@name))
  end

  def init(num) do
    Logger.info("ProducerConsumer an init kick-off number is #{num}")
    subscription = [{StageProducer, min_demand: 1, max_demand: 10}]
    {:producer_consumer, num, subscribe_to: subscription}
  end

  @doc """
  a `producer_consumer` will almost always want to `handle_events` by emitting events.
  """
  def handle_events(events, _from, state) do
    events = Enum.map(events, & &1 * state)
    {:noreply, events, state}
  end

  defp name, do: __MODULE__
end
