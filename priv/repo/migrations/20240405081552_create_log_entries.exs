defmodule DogAPI.Repo.Migrations.CreateLogEntries do
  use Ecto.Migration

  def change do
    create table(:log_entries, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :level, :string
      add :message, :string
      add :timestamp, :utc_datetime

      timestamps(type: :utc_datetime_usec)
    end
  end
end
