defmodule DogAPI.DSL.Recursive.Step do
  @moduledoc false

  defstruct [:name, :number, :__identifier__, steps: []]
end
