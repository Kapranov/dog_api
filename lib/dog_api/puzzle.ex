defmodule DogAPI.Puzzle do
  @moduledoc """
  """

  def run do
    array = Enum.to_list(1..10_000)

    [1, 10, 100, 1_000, 10_000]
    |> Map.new(fn idx ->
      {"access at #{idx}", fn -> Enum.at(array, idx) end}
    end)
    |> Benchee.run
  end
end
