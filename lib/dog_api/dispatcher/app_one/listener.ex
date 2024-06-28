defmodule AppOne.Listener do
  @moduledoc """
  AppOne listener

  ## Examples.

      iex> {:ok, app_one} = AppOne.Listener.start_link()
      {:ok, app_one}

  """

  use DogAPI.Dispatcher.Listener

  def on_message(%{name: "app_one_hello", payload: payload}) do
    AppOne.hello(payload)
  end

  def on_message(_), do: :nothing
end
