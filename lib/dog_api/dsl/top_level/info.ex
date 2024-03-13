defmodule DogAPI.DSL.TopLevel.Info do
  @moduledoc false

  use Spark.InfoGenerator, extension: DogAPI.DSL.TopLevel.Dsl, sections: [:steps]
end
