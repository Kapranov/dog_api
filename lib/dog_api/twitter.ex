defmodule DogAPI.Twitter do
  @moduledoc """
  How to use GenStage to Consumer Twitter API.

  GenStage are Elixir behaviors for exchanging events
  with back-pressure between Elixir processes.
  """

end

defmodule DogAPI.Twitter.Producer do
  @moduledoc false

  use GenStage

  @name __MODULE__

  def start_link(sentence \\ "") do
    GenStage.start_link(@name, sentence, name: @name)
  end

  def init(initial_state), do: {:producer, initial_state}

  def handle_demand(demand, state) do
    IO.inspect("Demand: #{demand}, state: #{state}", label: "STATE")
    letters = state |> String.graphemes()
    letters_to_consumer = Enum.take(letters, demand)
    sentence_left = String.slice(state, demand, length(letters))
    {:noreply, letters_to_consumer, sentence_left}
  end
end

defmodule DogAPI.Twitter.Consumer do
  @moduledoc false

  use GenStage

  require Logger

  alias DogAPI.Twitter.Producer

  @name __MODULE__

  def start_link(args \\ ""), do: GenStage.start_link(@name, args)

  def init(args) do
    Logger.info("Init Consuming words")
    subscribe_options = [{Producer, min_demand: 0, max_demand: 20}]
    {:consumer, args, subscribe_to: subscribe_options}
  end

  def handle_events(events, _from, state) do
    Logger.info("Consumer State: #{state}")

    words = Enum.join(events)
    sentence = state <> words

    Logger.info("Final State: #{sentence}")
    {:noreply, [], sentence}
  end
end

defmodule DogAPI.Twitter.Pro do
  @moduledoc false

  use GenStage

  @name __MODULE__

  def start_link(args \\ []) do
    GenStage.start_link(@name, %{events: args}, name: @name)
  end

  def init(initial_state), do: {:producer, initial_state}

  def handle_demand(demand, state) do
    events =
      if state.events >= demand do
        state.events
      else
        get_data_from_some_source()
      end

    {events_to_dispatch, events_remained} = Enum.split(events, demand)

    {:noreply, events_to_dispatch, %{state | events: events_remained}}
  end

  defp get_data_from_some_source, do: []
end

defmodule DogAPI.Twitter.Tp do
  @moduledoc false

  alias DogAPI.Twitter.Pro

  @name __MODULE__

  def start_link(args) do
    GenStage.start_link(@name, args)
  end

  def init(args) do
    {:consumer, args, subscribe_to: [Pro]}
  end

  def handle_events(_events, _from, state) do
    {:noreply, [], state}
  end
end
