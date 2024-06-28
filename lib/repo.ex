defmodule DogAPI.Repo do
  @moduledoc """
  DogAPI Repo.
  """

  use Ecto.Repo, otp_app: :dog_api, adapter: Ecto.Adapters.Postgres
end
