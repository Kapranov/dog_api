defmodule DogAPI.PingServerRegistry do
  @moduledoc """
  """

  def start_link do
    Registry.start_link(keys: :unique, name: name())
  end

  def via_tuple(key) do
    {:via, Registry, {name(), key}}
  end

  def child_spec(_) do
    Supervisor.child_spec(
      Registry,
      id: name(),
      start: {name(), :start_link, []}
    )
  end

  def name, do: __MODULE__
end
