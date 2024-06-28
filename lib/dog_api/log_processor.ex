defmodule DogAPI.LogProcessor do
  @moduledoc """
  """

  alias DogAPI.LogProducer

  use GenStage

  @name "Processor"

  @doc """

  ## Examples.

      iex> {:ok, error} = DogAPI.LogProcessor.start_link("ERROR")
      error
      iex> {:ok, info}  = DogAPI.LogProcessor.start_link("INFO")
      info
      iex> {:ok, warn}  = DogAPI.LogProcessor.start_link("WARN")
      warn

  """
  def start_link(log_level) do
    GenStage.start_link(name(), log_level, name: String.to_atom("#{@name}.#{log_level}"))
  end

  def init(log_level) do
    subscription = [{LogProducer, max_demand: 10}]
    {:producer_consumer, log_level, subscribe_to: subscription}
  end

  def handle_events([log], _from, log_level) do
    [_timestamp, level, message] = String.split(log)
    if level == log_level do
      IO.puts("Processing #{log_level} log... #{message}")
    end
    {:noreply, [], log_level}
  end

  defp name, do: __MODULE__
end
