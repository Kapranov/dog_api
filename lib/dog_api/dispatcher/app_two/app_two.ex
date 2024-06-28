defmodule AppTwo do
  @moduledoc """
  Documentation for AppTwo.
  """

  require Logger

  def hello(payload) do
    Logger.info("Hello from AppTwo: #{inspect(payload)}")
  end
end
