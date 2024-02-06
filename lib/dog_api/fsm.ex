defmodule DogAPI.Fsm do
  @moduledoc """
  Elixir itself is heavily powered by macros. Many constructs, such as
  `defmodule`, `def`, `if`, `unless`, and even `defmacro` are actually
  macros. This keeps the language core minimal, and simplifies further
  extensions to the language. Related, but somewhat less known is the
  possibility to generate functions on the fly:

  * `initial/0`
  * `pause/1`
  * `resume/1`
  * `stop/1`

  ## Example.

      iex> DogAPI.Fsm.initial
      :running
      iex> DogAPI.Fsm.initial |> DogAPI.Fsm.pause
      :paused
      iex> DogAPI.Fsm.initial |> DogAPI.Fsm.pause |> DogAPI.Fsm.pause
      :error
      iex> DogAPI.Fsm.initial |> DogAPI.Fsm.pause |> DogAPI.Fsm.resume
      :running
      iex> DogAPI.Fsm.initial |> DogAPI.Fsm.pause |> DogAPI.Fsm.stop
      :stopped

  """

  fsm = [
    paused: {:pause, :error},
    paused: {:resume, :running},
    paused: {:stop, :stopped},
    running: {:pause, :paused},
    running: {:stop, :stopped}
  ]

  for {state, {action, next_state}} <- fsm do
    def unquote(action)(unquote(state)), do: unquote(next_state)
  end

  def initial, do: :running
end
