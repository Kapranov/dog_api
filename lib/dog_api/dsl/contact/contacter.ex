defmodule DogAPI.DSL.Contact.Contacter do
  @moduledoc false

  @callback contact(DogAPI.DSL.Contact.t(), message :: String.t()) :: {:ok, term} | {:error, term}
end
