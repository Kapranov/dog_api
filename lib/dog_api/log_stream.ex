defmodule DogAPI.LogStream do
  @moduledoc """
  Building Concurrent ETL Pipelines with Elixir and GenStage.
  """

  def start_link, do: Task.start_link(fn -> generate_logs() end)

  def daytime, do: Date.utc_today() |> to_string

  defp generate_logs do
    Stream.cycle(["INFO", "WARN", "ERROR"])
    |> Stream.zip(Stream.interval(1_000))
    |> Enum.each(fn {level, _} ->
      IO.puts("#{timestamp()} #{level} information...")
    end)
  end

  defp timestamp do
    {erl_date, erl_time} = :calendar.local_time()
    {:ok, time} = Time.from_erl(erl_time)
    {:ok, date} = Date.from_erl(erl_date)
    time = Calendar.strftime(time, "%c", preferred_datetime: "%H:%M:%S")
    date = Calendar.strftime(date, "%c", preferred_datetime: "%m-%d-%Y")
    "[#{date} #{time}]"
  end
end
