defmodule RetryTest do
  use ExUnit.Case
  import DogAPI.Retry
  doctest DogAPI.Retry

  @count 10

  test "#ok when max_attempts is 0 and response is 0" do
    {:ok, agent} = Agent.start fn -> 0 end

    assert is_pid(agent) == true
    assert :sys.get_state(agent) == 0

    request = fn ->
      Agent.update agent, fn(i) -> i end
      {:ok, %HTTPoison.Response{status_code: 200}}
    end

    assert {:ok, %HTTPoison.Response{status_code: 200}} = autoretry(request.(), [max_attempts: 0])
    assert 0 = Agent.get(agent, &(&1))
    assert :sys.get_state(agent) == 0
  end

  test "#ok when max_attempts is 1 and response is 1" do
    {:ok, agent} = Agent.start fn -> 0 end

    assert is_pid(agent) == true
    assert :sys.get_state(agent) == 0

    request = fn ->
      Agent.update agent, fn(i) -> i + 1 end
      {:ok, %HTTPoison.Response{status_code: 200}}
    end

    assert {:ok, %HTTPoison.Response{status_code: 200}} = autoretry(request.(), [max_attempts: 1])
    assert 1 = Agent.get(agent, &(&1))
    assert :sys.get_state(agent) == 1
  end

  test "#ok when max_attempts is 2 and response is 2" do
    {:ok, agent} = Agent.start fn -> 0 end

    assert is_pid(agent) == true
    assert :sys.get_state(agent) == 0

    request = fn ->
      Agent.update agent, fn(i) -> i + 2 end
      {:ok, %HTTPoison.Response{status_code: 200}}
    end

    assert {:ok, %HTTPoison.Response{status_code: 200}} = autoretry(request.(), [max_attempts: 2])
    assert 2 = Agent.get(agent, &(&1))
    assert :sys.get_state(agent) == 2
  end

  test "#ok when max_attempts is 99 and response is 99" do
    {:ok, agent} = Agent.start fn -> 0 end

    assert is_pid(agent) == true
    assert :sys.get_state(agent) == 0

    request = fn ->
      Agent.update agent, fn(i) -> i + 99 end
      {:ok, %HTTPoison.Response{status_code: 200}}
    end

    assert {:ok, %HTTPoison.Response{status_code: 200}} = autoretry(request.(), [max_attempts: 99])
    assert 99 = Agent.get(agent, &(&1))
    assert :sys.get_state(agent) == 99
  end

  test "#error when max_attempts is 0 and response is 2" do
    {:ok, agent} = Agent.start fn -> 0 end

    assert is_pid(agent) == true
    assert :sys.get_state(agent) == 0

    request = fn ->
      Agent.update agent, fn(i) -> i + 1 end
      {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}}
    end

    assert {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}} = autoretry(request.(), [max_attempts: 0])
    assert 2 = Agent.get(agent, &(&1))
    assert :sys.get_state(agent) == 2
  end

  test "when max_attempts is 1 and response is 2" do
    {:ok, agent} = Agent.start fn -> 0 end

    assert is_pid(agent) == true
    assert :sys.get_state(agent) == 0

    request = fn ->
      Agent.update agent, fn(i) -> i + 1 end
      {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}}
    end

    assert {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}} = autoretry(request.(), [max_attempts: 1])
    assert 2 = Agent.get(agent, &(&1))
    assert :sys.get_state(agent) == 2
  end

  test "when max_attempts is 2 and response is 2" do
    {:ok, agent} = Agent.start fn -> 0 end

    assert is_pid(agent) == true
    assert :sys.get_state(agent) == 0

    request = fn ->
      Agent.update agent, fn(i) -> i + 1 end
      {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}}
    end

    assert {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}} = autoretry(request.(), [max_attempts: 2])
    assert 2 = Agent.get(agent, &(&1))
    assert :sys.get_state(agent) == 2
  end

  test "when max_attempts is 10 and response is 10" do
    {:ok, agent} = Agent.start fn -> 0 end

    assert is_pid(agent) == true
    assert :sys.get_state(agent) == 0

    request = fn ->
      Agent.update agent, fn(i) -> i + 1 end
      {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}}
    end

    assert {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}} = autoretry(request.(), [max_attempts: 10])
    assert 10 = Agent.get(agent, &(&1))
    assert :sys.get_state(agent) == 10
  end

  test "when max_attempts is 99 and response is 99" do
    {:ok, agent} = Agent.start fn -> 0 end

    assert is_pid(agent) == true
    assert :sys.get_state(agent) == 0

    request = fn ->
      Agent.update agent, fn(i) -> i + 1 end
      {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}}
    end

    assert {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}} = autoretry(request.(), [max_attempts: 99])
    assert 99 = Agent.get(agent, &(&1))
    assert :sys.get_state(agent) == 99
  end

  test "nxdomain errors" do
    {:ok, agent} = Agent.start fn -> 0 end
    request = fn ->
      Agent.update agent, fn(i) -> i + 1 end
      {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}}
    end

    assert {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}} = autoretry(request.())
    assert 5 = Agent.get(agent, &(&1))
  end

  test "500 errors" do
    {:ok, agent} = Agent.start fn -> 0 end
    request = fn ->
      Agent.update agent, fn(i) -> i + 1 end
      {:ok, %HTTPoison.Response{status_code: 500}}
    end

    assert {:ok, %HTTPoison.Response{status_code: 500}} = autoretry(request.())
    assert 5 = Agent.get(agent, &(&1))
  end

  test "errors other than nxdomain/timeout by default" do
    {:ok, agent} = Agent.start fn -> 0 end
    request = fn ->
      Agent.update agent, fn(i) -> i + 1 end
      {:error, %HTTPoison.Error{id: nil, reason: :other}}
    end

    assert {:error, %HTTPoison.Error{id: nil, reason: :other}} = autoretry(request.())
    assert 1 = Agent.get(agent, &(&1))
  end

  test "include other error types" do
    {:ok, agent} = Agent.start fn -> 0 end
    request = fn ->
      Agent.update agent, fn(i) -> i + 1 end
      {:error, %HTTPoison.Error{id: nil, reason: :other}}
    end

    assert {:error, %HTTPoison.Error{id: nil, reason: :other}} = autoretry(request.(), retry_unknown_errors: true)
    assert 5 = Agent.get(agent, &(&1))
  end

  test "404s by default" do
    {:ok, agent} = Agent.start fn -> 0 end
    request = fn ->
      Agent.update agent, fn(i) -> i + 1 end
      {:ok, %HTTPoison.Response{status_code: 404}}
    end

    assert {:ok, %HTTPoison.Response{status_code: 404}} = autoretry(request.())
    assert 1 = Agent.get(agent, &(&1))
  end

  test "include 404s" do
    {:ok, agent} = Agent.start fn -> 0 end
    request = fn ->
      Agent.update agent, fn(i) -> i + 1 end
        {:ok, %HTTPoison.Response{status_code: 404}}
    end

    assert {:ok, %HTTPoison.Response{status_code: 404}} = autoretry(request.(), [include_404s: true])
    assert 5 = Agent.get(agent, &(&1))
  end

  test "successful" do
    {:ok, agent} = Agent.start fn -> 0 end
    request = fn ->
      Agent.update agent, fn(i) -> i + @count end
      {:ok, %HTTPoison.Response{status_code: 200}}
    end

    assert {:ok, %HTTPoison.Response{status_code: 200}} = autoretry(request.())
    assert @count = Agent.get(agent, &(&1))
    assert :sys.get_state(agent) == @count
  end

  test "1 failure followed by 1 successful" do
    {:ok, agent} = Agent.start fn -> 0 end
    request = fn ->
      if Agent.get_and_update(agent, fn(i) -> {i + 1, i + 1} end) > 1 do
        {:ok, %HTTPoison.Response{status_code: 200}}
      else
        {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}}
      end
    end

    assert {:ok, %HTTPoison.Response{status_code: 200}} = autoretry(request.())
    assert 2 = Agent.get(agent, &(&1))
  end

  test "4 failures followed by 1 successful" do
    {:ok, agent} = Agent.start fn -> 0 end
    request = fn ->
      if Agent.get_and_update(agent, fn(i) -> {i + 1, i + 1} end) > 4 do
        {:ok, %HTTPoison.Response{status_code: 200}}
      else
        {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}}
      end
    end

    assert {:ok, %HTTPoison.Response{status_code: 200}} = autoretry(request.())
    assert 5 = Agent.get(agent, &(&1))
  end

  test "#get when successful with `%HTTPoison.Response{}`" do
    url = "https://httpbin.org/delay/4"
    opts = Keyword.merge([
      max_attempts: 5,
      wait: 1,
      include_404s: false,
      retry_unknown_errors: false,
      attempt: 0
    ], [attempt: 1])
    assert {:ok, %HTTPoison.Response{status_code: code, body: _}} = autoretry(HTTPoison.get(url), opts)
    assert code == 200
  end

  test "#get when timeout with `%HTTPoison.Response{}`" do
    url = "https://httpbin.org/delay/5"
    opts = Keyword.merge([
      max_attempts: 5,
      wait: 1,
      include_404s: false,
      retry_unknown_errors: false,
      attempt: 0
    ], [attempt: 1])
    assert {:error, %HTTPoison.Error{id: nil, reason: :timeout}} = autoretry(HTTPoison.get(url), opts)
  end

  test "#next_attempt when `infinity`" do
    opts = Keyword.merge([
      max_attempts: :infinity,
      wait: 1,
      include_404s: true,
      retry_unknown_errors: true,
      attempt: 0
    ], [attempt: 1])

    {:ok, agent} = Agent.start fn -> 0 end

    assert is_pid(agent) == true
    assert :sys.get_state(agent) == 0

    request = fn ->
      Agent.update agent, fn(i) -> i + 1 end
      {:ok, %HTTPoison.Response{status_code: 200}}
    end
    assert {:ok, %HTTPoison.Response{status_code: 200}} = autoretry(request.(), opts)
    assert 1 = Agent.get(agent, &(&1))
  end

  test "#next_attempt when `attempt` is 5" do
    opts = Keyword.merge([
      max_attempts: 5,
      wait: 1,
      include_404s: true,
      retry_unknown_errors: true,
      attempt: 0
    ], [attempt: 5])

    {:ok, agent} = Agent.start fn -> 0 end

    assert is_pid(agent) == true
    assert :sys.get_state(agent) == 0

    request = fn ->
      Agent.update agent, fn(i) -> i + 1 end
      {:ok, %HTTPoison.Response{status_code: 200}}
    end
    assert {:ok, %HTTPoison.Response{status_code: 200}} = autoretry(request.(), opts)
    assert 1 = Agent.get(agent, &(&1))
  end
end
