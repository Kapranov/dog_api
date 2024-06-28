defmodule DogAPI.LogProducer do
  @moduledoc """
  GenStage is a behavior abstraction for working with Producer and Consumer models,
  offering back-pressure and other complex features essential for high-volume data
  processing tasks like ETL. GenStage was built to support data-flow computations
  like concurrent processing, queuing, staged processing, and system event handling
  among others.

  Data Pipelines in Elixir and Understanding ETL

  The first concept needed to create a data pipeline is ETL, which stands for Extract,
  Transform, and Load. In theory, ETL is pretty simple, but in practice it can get
  quite complicated. Let’s tackle the simple case.

  Extraction is pulling data from a source. It could be your app’s primary database;
  it could be some third party API. Unfortunately, most commonly it’s just some poorly
  formatted Excel file someone threw at you. If it’s something that can hold data, it
  can be a source.

  Loading is inserting that data into a data store. The data store could be the same
  database the original data came from, an ElasticSearch instance, or part of a
  machine learning dataset. Like with Extraction, if it can hold data, it can be a
  destination.

  Transformation is the process of getting the data to a cleaner state. Once you’ve
  chosen the destination, there will be some requirements of the data in order to load
  it in. This could be things like formatting or data normalization. In almost all
  circumstances the loaded data will be “cleaner” than the extracted data.

  """

  use GenStage

  @doc """
  Starts the broadcaster.

  ## Examples.

      iex> {:ok, producer} = DogAPI.LogProducer.start_link
      producer

  """
  def start_link, do: GenStage.start_link(name(), :ok, name: name())

  @doc """
  Sends a log and returns only after the log is dispatched.

  ## Examples.

      iex> DogAPI.LogProducer.push_log("2024-04-01 ERROR interesting")
      iex> DogAPI.LogProducer.push_log("2024-04-02 INFO  interesting")
      iex> DogAPI.LogProducer.push_log("2024-04-03 WARN  interesting")
      iex> DogAPI.LogProducer.push_log("2024-04-04 ERROR interesting")
      iex> DogAPI.LogProducer.push_log("2024-04-05 INFO  interesting")
      iex> DogAPI.LogProducer.push_log("2024-04-06 WARN  interesting")
      iex> DogAPI.LogProducer.push_log("2024-04-07 ERROR interesting")
      iex> DogAPI.LogProducer.push_log("2024-04-08 INFO  interesting")
      iex> DogAPI.LogProducer.push_log("2024-04-09 WARN  interesting")
      iex> DogAPI.LogProducer.push_log("2024-04-10 ERROR interesting")
      iex> DogAPI.LogProducer.push_log("2024-04-11 INFO  interesting")
      iex> DogAPI.LogProducer.push_log("2024-04-12 WARN  interesting")
      iex> DogAPI.LogProducer.push_log("2024-04-13 ERROR interesting")
      iex> DogAPI.LogProducer.push_log("2024-04-14 INFO  interesting")
      iex> DogAPI.LogProducer.push_log("2024-04-15 WARN  interesting")
      iex> DogAPI.LogProducer.push_log("2024-04-16 ERROR interesting")
      iex> DogAPI.LogProducer.push_log("2024-04-17 INFO  interesting")
      iex> DogAPI.LogProducer.push_log("2024-04-18 WARN  interesting")
      iex> DogAPI.LogProducer.push_log("2024-04-19 ERROR interesting")
      iex> DogAPI.LogProducer.push_log("2024-04-20 INFO  interesting")
      iex> DogAPI.LogProducer.push_log("2024-04-21 WARN  interesting")

  """
  def push_log(log, timeout \\ 5_000) do
    GenStage.call(name(), {:push_log, log}, timeout)
  end

  def init(:ok) do
    {:producer, [], dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_call({:push_log, log}, _from, state) do
    {:reply, :ok, [log], state}
  end

  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end

  defp name, do: __MODULE__
end
