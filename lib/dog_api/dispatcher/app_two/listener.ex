defmodule AppTwo.Listener do
  @moduledoc """
  AppTwo listener

  ## Examples.

      iex> {:ok, app_two} = AppTwo.Listener.start_link()
      {:ok, app_two}

  """

  use DogAPI.Dispatcher.Listener

  def on_message(%{name: "app_two_hello", payload: payload}) do
    AppTwo.hello(payload)
  end

  def on_message(action), do: action
end
