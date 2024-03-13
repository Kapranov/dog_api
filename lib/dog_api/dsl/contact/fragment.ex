defmodule DogAPI.DSL.Contact.TedDansenFragment do
  @moduledoc false

  use Spark.Dsl.Fragment, of: DogAPI.DSL.Contact

  address do
    street("foobar")
  end
end
