defmodule DogAPI.PingServer do
  @moduledoc """
  """

  alias DogAPI.PingServerRegistry

  use GenServer

  def start, do: GenServer.start_link(name(), nil, name: via_tuple())

  def ping do
    IO.inspect("Executing GenServer on node - #{node()}")
    GenServer.call(via_tuple(), :ping)
  end

  @impl GenServer
  def init(_), do: {:ok, nil}

  @impl GenServer
  def handle_call(:ping, _, state), do: {:reply, :pong, state}

  defp via_tuple, do: PingServerRegistry.via_tuple(name())

  defp name, do: __MODULE__
end
