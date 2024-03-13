defmodule DogAPI.DSL.Recursive.Info do
  @moduledoc false

  use Spark.InfoGenerator, extension: DogAPI.DSL.Recursive.Dsl, sections: [:steps]
end
