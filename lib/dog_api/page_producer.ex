defmodule DogAPI.PageProducer do
  @moduledoc """
  """

  use GenServer
  require Logger

  def start_link, do: GenStage.start_link(name(), [], name: name())

  def init([]) do
    Logger.info("PageProducer init")
    {:producer, []}
  end

  def scrape_pages(pages) when is_list(pages) do
    GenStage.cast(name(), {:pages, pages})
  end

  def handle_cast({:pages, pages}, state) do
    {:noreply, pages, state}
  end

  def handle_demand(demand, state) do
    Logger.info("PageProducer received demand for #{demand} pages")
    events = []
    {:noreply, events, state}
  end

  defp name, do: __MODULE__
end
