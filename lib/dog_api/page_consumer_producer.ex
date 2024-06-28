defmodule DogAPI.PageConsumerProducer do
  @moduledoc """
  """

  alias DogAPI.PageProducer
  alias DogAPI.Scraper

  use GenStage
  require Logger

  def start_link, do: GenStage.start_link(name(), [], name: name())

  def init([]) do
    Logger.info("PageProducerConsumer init")

    subscription = [
      {PageProducer, min_demand: 0, max_demand: 1}
    ]
    {:producer_consumer, [], subscribe_to: subscription}
  end

  def handle_events(events, _from, state) do
    Logger.info("PageProducerConsumer received #{inspect(events)}")
    events = Enum.filter(events, &Scraper.online?/1)
    {:noreply, events, state}
  end

  defp name, do: __MODULE__
end
