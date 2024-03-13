defmodule TempDirectoryTest do
  use ExUnit.Case

  @tag :tmp_dir
  test "temp directories are awesome!", %{tmp_dir: tmp_dir} do
    dbg(tmp_dir)
    path = Path.join(tmp_dir, "greeting.txt")
    File.write!(path, "Aloha!")
    assert "Aloha!" == File.read!(path)
  end

  test "get informations of module" do
    assert [vsn: [_num]] = DogAPI.Retry.__info__(:attributes)
    assert [
      {:version, ~c"8.4.2"},
      {:options, [
        :no_spawn_compiler_process,
        :from_core, :no_core_prepare,
        :no_auto_import
      ]},
      {:source, ~c"/home/kapranov/Projects/dog_api/lib/dog_api/retry.ex"}] =
        DogAPI.Retry.__info__(:compile)
    assert [{:handle_response, 1}, {:next_attempt, 2}] = DogAPI.Retry.__info__(:functions)
    assert [{:autoretry, 1}, {:autoretry, 2}] = DogAPI.Retry.__info__(:macros)
    assert DogAPI.Retry = DogAPI.Retry.__info__(:module)
    assert DogAPI.Retry.__info__(:struct) == nil
  end
end
