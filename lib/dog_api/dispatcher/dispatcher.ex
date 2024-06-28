defmodule DogAPI.Dispatcher do
  @moduledoc """
  DogAPI.Dispatcher is for dispatching messages.

  ## Examples.

      iex> DogAPI.Dispatcher.message(%{name: "app_one_hello", payload: "some_kind_of_payload"}
      :ok

  """

  use GenStage
  require Logger


  def start_link, do: GenStage.start_link(name(), :ok, name: name())

  def message(message), do: GenStage.cast(name(), message)

  def init(:ok), do: {:producer, %{enabled: true}, dispatcher: GenStage.BroadcastDispatcher}

  def handle_info(:disable, state) do
    {:noreply, [], %{state | enabled: false}}
  end

  def handle_info(:enable, state) do
    {:noreply, [], %{state | enabled: true}}
  end

  def handle_cast(message, %{enabled: true} = state) when is_map(message) do
    Logger.info("Dispatch message: #{inspect(message)}")
    {:noreply, [message], state}
  end

  def handle_demand(_demand, state), do: {:noreply, [], state}

  defp name, do: __MODULE__
end
