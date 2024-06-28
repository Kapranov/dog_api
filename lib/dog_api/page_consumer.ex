defmodule DogAPI.PageConsumer do
  @moduledoc """
  """

  alias DogAPI.PageConsumerProducer

  use GenServer

  require Logger

  def start_link, do: GenStage.start_link(name(), [])

  def init([]) do
    Logger.info("PageConsumer init")
    {:consumer, [], subscribe_to: [PageConsumerProducer]}
  end

  def handle_events(events, _from, state) do
    Logger.info("PageConsumer received #{inspect(events)}")
    {:noreply, [], state}
  end

  defp name, do: __MODULE__
end
