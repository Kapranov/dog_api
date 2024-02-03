defmodule DogAPI.Retry do
  @moduledoc """
  See `#{__MODULE__}.autoretry/2`

  Will retry 5 times waiting 15s between each before returning. Therefore, your process
  could end up waiting up to 75 seconds (plus the request time) on the line below
  and end on the line function which will handle the response after success or failed retry.

  ## Example.

      iex> import DogAPI.Retry
      iex> HTTPoison.get("https://www.example.com") |> DogAPI.Retry.autoretry(max_attempts: 5, wait: 15_000, include_404s: false, retry_unknown_errors: false) |> DogAPI.Retry.handle_response()

      iex> opts = Keyword.merge([max_attempts: 5, wait: 1, include_404s: false, retry_unknown_errors: false, attempt: 0], [attempt: 1])
      iex> {:ok, %HTTPoison.Response{status_code: 200, body: _}} = DogAPI.Retry.autoretry(HTTPoison.get("https://www.example.com"), opts)

      iex> url = "https://httpbin.org/delay/4"
      iex> opts = Keyword.merge([max_attempts: 3, wait: 1, include_404s: false, retry_unknown_errors: false, attempt: 0], [attempt: 1])
      iex> {:ok, %HTTPoison.Response{status_code: 200, body: _}} = DogAPI.Retry.autoretry(HTTPoison.get(url), opts)

      iex> url = "https://httpbin.org/delay/5"
      iex> opts = Keyword.merge([max_attempts: 3, wait: 1, include_404s: false, retry_unknown_errors: false, attempt: 0], [attempt: 1])
      iex> {:error, %HTTPoison.Error{reason: :timeout, id: nil}} = DogAPI.Retry.autoretry(HTTPoison.get(url), opts)

  """

  @max_attempts 5
  @attempt 15_000
  @get_attempt Application.compile_env(:dog_api, :attempt)
  @get_include_404s Application.compile_env(:dog_api, :include_404s)
  @get_max_attempts Application.compile_env(:dog_api, :max_attempts)
  @get_retry_unknown_errors Application.compile_env(:dog_api, :retry_unknown_errors)
  @get_wait Application.compile_env(:dog_api, :wait)

  @doc """
  """
  defmacro autoretry(attempt, opts \\ []) do
    quote location: :keep, generated: true do
      attempt_fn = fn -> unquote(attempt) end
      opts = Keyword.merge([
        max_attempts: unquote(@get_max_attempts) || unquote(@max_attempts),
        wait: unquote(@get_wait) || unquote(@attempt),
        include_404s: unquote(@get_include_404s) || false,
        retry_unknown_errors: unquote(@get_retry_unknown_errors) || false,
        attempt: unquote(@get_attempt) || 1
      ],
      unquote(opts)
      )

      case attempt_fn.() do
        {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}} ->
          DogAPI.Retry.next_attempt(attempt_fn, opts)
        {:error, %HTTPoison.Error{id: nil, reason: :timeout}} ->
          DogAPI.Retry.next_attempt(attempt_fn, opts)
        {:error, %HTTPoison.Error{id: nil, reason: :closed}} ->
          DogAPI.Retry.next_attempt(attempt_fn, opts)
        {:error, %HTTPoison.Error{id: nil, reason: _}} = response ->
          if Keyword.get(opts, :retry_unknown_errors) do
            DogAPI.Retry.next_attempt(attempt_fn, opts)
          else
            response
          end
        {:ok, %HTTPoison.Response{status_code: 500}} ->
          DogAPI.Retry.next_attempt(attempt_fn, opts)
        {:ok, %HTTPoison.Response{status_code: 404}} = response ->
          if Keyword.get(opts, :include_404s) do
            DogAPI.Retry.next_attempt(attempt_fn, opts)
          else
            response
          end
        response ->
          response
      end
    end
  end

  def next_attempt(attempt, opts) do
    Process.sleep(opts[:wait])
    if opts[:max_attempts] == :infinity || opts[:attempt] < opts[:max_attempts] - 1 do
      opts = Keyword.put(opts, :attempt, opts[:attempt] + 1)
      autoretry(attempt.(), opts)
    else
      attempt.()
    end
  end

  def handle_response({:ok, response}) do
    response.status_code
  end
end
