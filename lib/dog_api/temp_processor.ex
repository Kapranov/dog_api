defmodule DogAPI.TempProcessor do
  @moduledoc """
  """

  use Broadway

  alias Broadway.Message

  @name __MODULE__

  def start_link(_opts) do
    Broadway.start_link(@name, name: @name, producer: [
      module: {DogAPI.CityProducer, []},
      transformer: {@name, :transform, []},
      rate_limiting: [
        allowed_messages: 60,
        interval: 60_000
      ]
    ],
    processors: [
      default: [concurrency: 5]
    ])
  end

  @impl true
  def handle_message(:default, message, _context) do
    message
    |> Message.update_data(fn {city, country} ->
      city_data = {city, country, DogAPI.TempFetcher.fetch_data(city, country)}
      DogAPI.TempTracker.update_coldest_city(city_data)
    end)
  end

  def transform(event, _opts) do
    %Message{data: event, acknowledger: {@name, :ack_id, :ack_data}}
  end

  def ack(:ack_id, _successful, _failed), do: :ok
end
