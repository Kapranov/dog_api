defmodule HttpRequestTest do
  use ExUnit.Case

  setup_all do
    Application.ensure_all_started(:inets)
    Application.ensure_all_started(:ssl)
    Application.ensure_all_started(:multipart)
    Application.put_env(:elixir, :dbg_callback, {Macro, :dbg, []})

    :ok
  end

  describe "Sending are requests returning a JSON payload" do
    test "#delete" do
      url = 'https://httpbin.org/delete'
      headers = [{'accept', 'application/json'}]

      http_request_opts = [
        ssl: [
          verify: :verify_peer,
          cacerts: :public_key.cacerts_get(),
          customize_hostname_check: [
            match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
          ]
        ]
      ]

      {:ok, {{'HTTP/1.1', status, status_msg}, _headers, body}} =
        :httpc.request(:delete, {url, headers}, http_request_opts, [])
      assert {status, status_msg, Jason.decode!(body)["args"]} == {200, 'OK', Map.new}
    end

    test "#get" do
      url = 'https://httpbin.org/get'
      headers = [{'accept', 'application/json'}]

      http_request_opts = [
        ssl: [
          verify: :verify_peer,
          cacerts: :public_key.cacerts_get(),
          customize_hostname_check: [
            match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
          ]
        ]
      ]

      {:ok, {{'HTTP/1.1', status, status_msg}, _headers, body}} =
        :httpc.request(:get, {url, headers}, http_request_opts, [])
      assert {status, status_msg, Jason.decode!(body)["args"]} == {200, 'OK', Map.new}
    end

    test "#patch" do
      url = 'https://httpbin.org/patch'
      headers = []
      content_type = 'application/json'
      body = Jason.encode!(%{hello: "Aloha!"})
      http_request_opts = [
        ssl: [
          verify: :verify_peer,
          cacerts: :public_key.cacerts_get(),
          customize_hostname_check: [
            match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
          ]
        ]
      ]

      {:ok, {{'HTTP/1.1', status, status_msg}, _headers, body}} =
        :httpc.request(:patch, {url, headers, content_type, body}, http_request_opts, [])

      assert {status, status_msg, Jason.decode!(body)["json"]} == {200, 'OK', %{"hello" => "Aloha!"}}
    end

    test "#post" do
      url = 'https://httpbin.org/post'
      headers = []
      content_type = 'application/json'
      body = Jason.encode!(%{hello: "Aloha!"})
      http_request_opts = [
        ssl: [
          verify: :verify_peer,
          cacerts: :public_key.cacerts_get(),
          customize_hostname_check: [
            match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
          ]
        ]
      ]

      {:ok, {{'HTTP/1.1', status, status_msg}, _headers, body}} =
        :httpc.request(:post, {url, headers, content_type, body}, http_request_opts, [])

      assert {status, status_msg, Jason.decode!(body)["json"]} == {200, 'OK', %{"hello" => "Aloha!"}}
    end

    test "#post without payload" do
      url = 'https://httpbin.org/post'
      headers = []
      content_type = ''
      body = ''
      http_request_opts = [
        ssl: [
          verify: :verify_peer,
          cacerts: :public_key.cacerts_get(),
          customize_hostname_check: [
            match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
          ]
        ]
      ]

      {:ok, {{'HTTP/1.1', status, status_msg}, _headers, body}} =
        :httpc.request(:post, {url, headers, content_type, body}, http_request_opts, [])

      assert {status, status_msg, Jason.decode!(body)["json"]} == {200, 'OK', nil}
    end

    test "#put" do
      url = 'https://httpbin.org/put'
      headers = []
      content_type = 'application/json'
      body = Jason.encode!(%{hello: "Aloha!"})
      http_request_opts = [
        ssl: [
          verify: :verify_peer,
          cacerts: :public_key.cacerts_get(),
          customize_hostname_check: [
            match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
          ]
        ]
      ]

      {:ok, {{'HTTP/1.1', status, status_msg}, _headers, body}} =
        :httpc.request(:put, {url, headers, content_type, body}, http_request_opts, [])

      assert {status, status_msg, Jason.decode!(body)["json"]} == {200, 'OK', %{"hello" => "Aloha!"}}
    end

    test "downloading a file" do
      url = 'https://www.rfc-editor.org/rfc/pdfrfc/rfc1149.txt.pdf'
      headers = []
      path_to_file =
        System.tmp_dir!()
        |> Path.join("rfc1149.txt.pdf")
        |> String.to_charlist()

      http_request_opts = [
        ssl: [
          verify: :verify_peer,
          cacerts: :public_key.cacerts_get(),
          customize_hostname_check: [
            match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
          ]
        ]
      ]

      {:ok, :saved_to_file} =
        :httpc.request(:get, {url, headers}, http_request_opts, [stream: path_to_file])
    end

    test "PTIN Information and the Freedom of Information Act" do
      file = "foia-extract.zip"
      url = 'https://www.irs.gov/pub/irs-utl/#{file}'
      headers = []
      path_to_file =
        System.tmp_dir!()
        |> Path.join(file)
        |> String.to_charlist()

      http_request_opts = [
        ssl: [
          verify: :verify_peer,
          cacerts: :public_key.cacerts_get(),
          customize_hostname_check: [
            match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
          ]
        ]
      ]

      {:ok, :saved_to_file} =
        :httpc.request(:get, {url, headers}, http_request_opts, [stream: path_to_file])

      {:ok, data} = :file.read_file(path_to_file)

      case :zip.unzip(data, [{:cwd, ~c'/tmp/'}]) do
        {:ok, [content]} ->
          assert to_string(content) == "/tmp/foia-extract.csv"
        {:error, error} ->
          assert error == nil
      end
    end

    test "uploading a file" do
      part = Multipart.Part.file_field("/tmp/rfc1149.txt.pdf", "my_file")
      assert %Multipart.Part{} = part

      multipart =
        Multipart.new()
        |> Multipart.add_part(part)

      content_length =
        multipart
        |> Multipart.content_length()
        |> Integer.to_string()
        |> String.to_charlist()

      content_type =
        multipart
        |> Multipart.content_type("multipart/form-data")
        |> String.to_charlist()

      url = 'https://httpbin.org/anything'
      headers = [{'Content-Length', content_length}]
      payload = Multipart.body_binary(multipart)

      http_request_opts = [
        ssl: [
          verify: :verify_peer,
          cacerts: :public_key.cacerts_get(),
          customize_hostname_check: [
            match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
          ]
        ]
      ]

      :httpc.request(:post, {url, headers, content_type, payload}, http_request_opts, [])

      {:ok, {{'HTTP/1.1', status, status_msg}, _headers, body}} =
        :httpc.request(:post, {url, headers, content_type, payload}, http_request_opts, [])

        assert {status, status_msg, Jason.decode!(body)["args"]} == {200, 'OK', Map.new}
        assert {status, status_msg, Jason.decode!(body)["data"]} == {200, 'OK', ""}
    end

    test "low-level tracing of HTTP interaction" do
      url = 'https://httpbin.org/get'
      headers = [{'content-type', 'application/json'}]
      http_request_opts = [
        ssl: [
          verify: :verify_peer,
          cacerts: :public_key.cacerts_get(),
          customize_hostname_check: [
            match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
          ]
        ]
      ]

      #:httpc.set_options([verbose: :debug])
      :httpc.request(:get, {url, headers}, http_request_opts, [])
    end
  end
end
