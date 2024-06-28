defmodule DogAPI.PrinterProducer do
  @moduledoc false

  use GenStage

  def start_link(binary_size) do
    GenStage.start_link(__MODULE__, binary_size)
  end

  def init(binary_size) do
    {:producer, binary_size}
  end

  def handle_demand(demand, binary_size = _state) do
    Process.sleep(Enum.random(1000..5000))

    events =
      Stream.repeatedly(fn -> :crypto.strong_rand_bytes(binary_size) end)
      |> Enum.take(demand)

    {:noreply, events, binary_size}
  end
end
