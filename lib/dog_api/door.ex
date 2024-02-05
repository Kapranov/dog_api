defmodule DogAPI.Door do
  @moduledoc """

  The known callbacks are:

  *   `:gen_statem.callback_mode/0` (function)
  *   `:gen_statem.code_change/4` (function)
  *   `:gen_statem.format_status/1` (function)
  *   `:gen_statem.format_status/2` (function)
  *   `:gen_statem.handle_event/4` (function)
  *   `:gen_statem.init/1` (function)
  *   `:gen_statem.state_name/3` (function)
  *   `:gen_statem.terminate/3` (function)

  ## Example.

      iex> {:ok, server} = DogAPI.Door.start_link
      {:ok, server}
      iex> :sys.get_state(server)
      {:locked, nil}
      iex> :gen_statem.call(server, :open)
      {:error, "invalid transition"}
      iex> :gen_statem.call(server, :unlock)
      {:ok, :unlocked}
      iex> :gen_statem.call(server, :open)
      {:ok, :opened}
      iex> :gen_statem.call(server, :close)
      {:ok, :unlocked}
      iex> :gen_statem.call(server, :lock)
      {:ok, :locked}
      iex> :gen_statem.call(server, :open)
      {:error, "invalid transition"}

  """


  @behaviour :gen_statem
  @name __MODULE__

  def start_link, do: :gen_statem.start_link(@name, :ok, [])

  @impl :gen_statem
  def init(_), do: {:ok, :locked, nil}

  @impl :gen_statem
  def callback_mode, do: :handle_event_function

  @impl true
  def handle_event({:call, from}, :unlock, :locked, data) do
    {:next_state, :unlocked, data, [{:reply, from, {:ok, :unlocked}}]}
  end

  @impl true
  def handle_event({:call, from}, :lock, :unlocked, data) do
    {:next_state, :locked, data, [{:reply, from, {:ok, :locked}}]}
  end

  @impl true
  def handle_event({:call, from}, :open, :unlocked, data) do
    {:next_state, :opened, data, [{:reply, from, {:ok, :opened}}]}
  end

  @impl true
  def handle_event({:call, from}, :close, :opened, data) do
    {:next_state, :unlocked, data, [{:reply, from, {:ok, :unlocked}}]}
  end

  @impl true
  def handle_event({:call, from}, _event, _content, data) do
    {:keep_state, data, [{:reply, from, {:error, "invalid transition"}}]}
  end
end
