defmodule DogAPI.BaseWrapper do
  @moduledoc false

  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      use HTTPoison.Base

      base_url = Keyword.get(opts, :base_url)

      def process_request_headers(headers) do
        opts = [
          {"Accept", "application/json"},
          {"Content-Type", "application/json"}
        ]

        headers ++ opts
      end

      def process_url(endpoint), do: URI.merge(URI.parse(unquote(base_url)), endpoint) |> to_string()
      def process_request_body(body), do: Jason.encode!(body)
      def process_response_body(response), do: Jason.decode!(response)

      def delete?(url) do
        response = delete(url)
        DogAPI.BaseWrapper.parse_delete(response)
      end

      def get?(url) do
        response = get(url)
        DogAPI.BaseWrapper.parse_get(response)
      end

      def patch?(url, body) do
        response = patch(url, body)
        DogAPI.BaseWrapper.parse_patch(response)
      end

      def post?(url, body) do
        response = post(url, body)
        DogAPI.BaseWrapper.parse_post(response)
      end

      def put?(url, body) do
        response = put(url, body)
        DogAPI.BaseWrapper.parse_put(response)
      end

      def status?(method, url) do
        case method do
          :delete -> {:ok, :ok}
            response = delete(url, [])
            DogAPI.BaseWrapper.parse_delete(response)
          :get ->
            response = get(url)
            DogAPI.BaseWrapper.parse_get(response)
          :patch ->
            response = patch(url, [])
            DogAPI.BaseWrapper.parse_patch(response)
          :post -> {:ok, :ok}
            response = post(url, [])
            DogAPI.BaseWrapper.parse_post(response)
          :put ->
            response = put(url, [])
            DogAPI.BaseWrapper.parse_put(response)
        end
      end
    end
  end

  def parse_delete({:ok, %HTTPoison.Response{status_code: code, body: body}}) when code in 200..299 do
    data = body["json"]
    {:ok, data}
  end

  def parse_get({:ok, %HTTPoison.Response{status_code: code, body: body}}) when code in 200..299 do
    data = body["args"]
    {:ok, data}
  end

  def parse_patch({:ok, %HTTPoison.Response{status_code: code, body: body}}) when code in 200..299 do
    data = body["json"]
    {:ok, data}
  end

  def parse_post({:ok, %HTTPoison.Response{status_code: code, body: body}}) when code in 200..299 do
    data = body["json"]
    {:ok, data}
  end

  def parse_put({:ok, %HTTPoison.Response{status_code: code, body: body}}) when code in 200..299 do
    data = body["json"]
    {:ok, data}
  end
end
