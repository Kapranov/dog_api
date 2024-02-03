defmodule DogAPI.Wrapper do
  @moduledoc false

  use DogAPI.BaseWrapper, base_url: "https://httpbin.org/"

  @methods [:delete, :get, :patch, :post, :put]
  @phrase "Generates responses with given status code"
  @status "/status/{code}"
  @constants [
    delete: "#{@phrase} DELETE #{@status}",
    get: "#{@phrase} GET    #{@status}",
    patch: "#{@phrase} PATCH  #{@status}",
    post: "#{@phrase} POST   #{@status}",
    put: "#{@phrase} PUT    #{@status}"
  ]

  def list_of_all_comments() do
    Enum.map(@constants, &Kernel.elem(&1, 1))
  end

  def delete do
    case delete?("delete") do
      {:ok, response} -> {:ok, response}
    end
  end

  def get do
    case get?("get") do
      {:ok, response} -> {:ok, response}
    end
  end

  def patch(data) do
    case patch?("patch", data) do
      {:ok, response} -> {:ok, response}
    end
  end

  def post(data) do
    case post?("post", data) do
      {:ok, response} -> {:ok, response}
    end
  end

  def put(data) do
    case put?("put", data) do
      {:ok, response} -> {:ok, response}
    end
  end

  def status(method, num) when (method in @methods) and (num in 200..299) do
    # data |> String.split("/") |> List.last |> String.to_integer
    # <<char, ta, tb, tc, td, te, tf, th ::bitstring>> = "status/200"
    case status?(method, "status/#{num}") do
      {:ok, response} -> {:ok, response}
    end
  end
end
