defmodule DogAPI.Exceptions do
  @moduledoc false

  alias DogAPI.DivisionByZeroError

  def div(a, b) do
    try do
      a / b
    rescue
      e in ArithmeticError ->
        reraise DivisionByZeroError, [message: e.message], __STACKTRACE__
    end
  end
end
