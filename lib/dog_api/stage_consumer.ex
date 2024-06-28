defmodule DogAPI.StageConsumer do
  @moduledoc """
  """

  use GenStage

  require Logger

  def start_link, do: GenStage.start_link(name(), :ok)

  def init(:ok) do
    Logger.info("Consumer init")
    subscription = [{String.to_atom("StageProcessor"), max_demand: 1}]
    {:consumer, :state_does_not_matter, [subscribe_to: subscription]}
  end

  @doc """
  a `consumer` will never want to `handle_events` by emitting events.
  """
  def handle_events(events, _from, state) do
    Process.sleep(1000)
    Logger.info("Consumer #{state}, received #{inspect(events)}")
    {:noreply, [], state}
  end

  defp name, do: __MODULE__
end
