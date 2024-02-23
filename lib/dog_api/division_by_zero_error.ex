defmodule DogAPI.DivisionByZeroError do
  @moduledoc false

  defexception [:message]

  @impl true
  def exception(value) do
    msg = "did not get what was expected, got: #{inspect(value)}"
    %DogAPI.DivisionByZeroError{message: msg}
  end
end
