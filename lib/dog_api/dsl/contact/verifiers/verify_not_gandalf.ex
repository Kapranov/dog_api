defmodule DogAPI.DSL.Contact.VerifyNotGandalf do
  @moduledoc false

  use Spark.Dsl.Verifier
  alias Spark.Dsl.Verifier

  def verify(dsl) do
    if DogAPI.DSL.Contact.Info.first_name(dsl) == "Gandalf" do
      {:error,
        Spark.Error.DslError.exception(
          message: "Cannot be gandalf",
          path: [:personal_details, :first_name],
          module: Verifier.get_persisted(dsl, :module)
        )
      }
    else
      :ok
    end
  end
end
