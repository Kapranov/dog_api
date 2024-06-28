defmodule DogAPI.Application do
  @moduledoc false

  use Application

  alias DogAPI.{
    CityProducer,
    PingServerRegistry,
    Repo,
    TempProcessor,
    TempTracker
  }

  @impl true
  def start(_type, _args) do
    children = [
      Repo,
      PingServerRegistry,
      # %{id: DogAPI.LogProducer, start: {DogAPI.LogProducer, :start_link, []}}
      TempTracker,
      CityProducer,
      TempProcessor
    ]
    opts = [strategy: :one_for_one, name: DogApi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
