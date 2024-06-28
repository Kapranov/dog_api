defmodule DogAPI.PrinterConsumer do
  @moduledoc false

  use GenStage

  def start_link do
    GenStage.start_link(__MODULE__, :nostate)
  end

  def init(:nostate) do
    {:consumer, :nostate}
  end

  def handle_events(binaries, _from, state) do
    Enum.each(binaries, &IO.inspect(&1, label: "Binary consumed in #{inspect(self())}"))
    {:noreply, _events = [], state}
  end
end
