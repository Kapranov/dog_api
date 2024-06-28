defmodule DogAPI.LogEntries do
  @moduledoc """
  """

  use Ecto.Schema
  import Ecto.Changeset

  @enforce_keys [:timestamp, :level, :message]
  defstruct [:timestamp, :level, :message]

  def changeset(entry, params \\ %{}) do
    entry
    |> cast(params, [:timestamp, :level, :message])
    |> validate_required([:timestamp, :level, :message])
    |> validate_length(:message, min: 1)
  end

  def validate_message_format(changeset) do
    validate_change(changeset, :message, fn :message, message ->
      if message =~ ~r/^Log Entry: .{10,}$/ do
        []
      else
        [{:message, "must begin with 'Log Entry: ' and be at least 10 characters long"}]
      end
    end)
  end
end
