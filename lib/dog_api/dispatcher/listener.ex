defmodule DogAPI.Dispatcher.Listener do
  @moduledoc """
  Listener for messages from dispatcher.

  ## Examples.


  iex>  {:ok, dispatcher} = DogAPI.Dispatcher.start_link()
  {:ok, dispatcher}

  """

  @callback on_message(message :: map) :: any

  @doc false
  defmacro __using__(_opts) do
    quote location: :keep do
      @behaviour DogAPI.Dispatcher.Listener

      use GenStage

      def start_link do
        GenStage.start_link(name(), :ok, name: name())
      end

      def init(:ok) do
        {:consumer, :ok, subscribe_to: [DogAPI.Dispatcher]}
      end

      def handle_events(messages, _from, state) do
        for message <- messages do
          on_message(message)
        end
        {:noreply, [], state}
      end

      def on_message(_), do: :nothing

      defp name, do: __MODULE__

      defoverridable on_message: 1
    end
  end
end
