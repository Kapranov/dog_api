defmodule DogAPI.LogEntry do
  @moduledoc """
  """

  defstruct [level: "INFO", message: "", timestamp: DateTime.utc_now]
end
