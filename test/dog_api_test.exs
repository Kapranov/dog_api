defmodule DogApiTest do
  use ExUnit.Case

  alias DogAPI.Wrapper.Constants

  setup_all do
    Application.ensure_all_started(:inets)
    Application.ensure_all_started(:ssl)
    Application.ensure_all_started(:multipart)
    Application.put_env(:elixir, :dbg_callback, {Macro, :dbg, []})

    :ok
  end

  describe "if comment exists at elixir-lang/elixir" do
    @comments Constants.list_of_all_comments()
    @website_copy_url "https://github.com/elixir-lang/elixir/blob/main/lib/elixir/"
    @file_ext ".md"

    for comment <- @comments do
      @comment comment
      @tag :external
      test "#{@comment} exists" do
        request_path = String.replace(@comment, ".", "/")
        request_url = "#{@website_copy_url}#{request_path}#{@file_ext}" |> to_charlist()
        {:ok, {{'HTTP/1.1', status, status_msg}, _headers, _body}} =
          :httpc.request(:head, {request_url, []}, [], [])
        assert {status, status_msg, @comment} == {200, 'OK', @comment}
      end
    end
  end

  describe "if comment exists at elixir-lang/elixir none an extension md" do
    @comments Constants.list_of_all_excepts()
    @website_copy_url "https://github.com/elixir-lang/elixir/blob/main/lib/elixir/"
    @file_ext ".cheatmd"

    for comment <- @comments do
      @comment comment
      @tag :external
      test "#{@comment} exists" do
        request_path = String.replace(@comment, ".", "/")
        request_url = "#{@website_copy_url}#{request_path}#{@file_ext}" |> to_charlist()
        {:ok, {{'HTTP/1.1', status, status_msg}, _headers, _body}} =
          :httpc.request(:head, {request_url, []}, [], [])
        assert {status, status_msg, @comment} == {200, 'OK', @comment}
      end
    end
  end
end
