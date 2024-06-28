defmodule AppOne do
  @moduledoc """
  Documentation for AppOne.
  """

  require Logger

  def hello(payload) do
    Logger.info("Hello from AppOne: #{inspect(payload)}")
  end
end
