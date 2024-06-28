defmodule DogAPI.PrinterProducerConsumer do
  @moduledoc false

  use GenStage

  def start_link do
    GenStage.start_link(__MODULE__, :nostate)
  end

  def init(:nostate) do
    {:producer_consumer, :nostate}
  end

  def handle_events(events, _from, :nostate) do
    events =
      for event <- events do
        {event, Base.encode64(:erlang.md5(event))}
      end

    {:noreply, events, :nostate}
  end
end
