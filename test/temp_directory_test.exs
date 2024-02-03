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
      {:version, ~c"8.4.1"},
      {:options, [
        :no_spawn_compiler_process,
        :from_core, :no_core_prepare,
        :no_auto_import
      ]},
      {:source, ~c"/home/kapranov/Projects/dog_api/lib/dog_api/retry.ex"}] =
        DogAPI.Retry.__info__(:compile)
    assert [{:next_attempt, 2}] = DogAPI.Retry.__info__(:functions)
    assert [{:autoretry, 1}, {:autoretry, 2}] = DogAPI.Retry.__info__(:macros)
    assert <<151, 32, 45, 67, 189, 62, 118, 60, 105, 71, 104, 34, 114, 87, 84, 205>> = DogAPI.Retry.__info__(:md5)
    assert DogAPI.Retry = DogAPI.Retry.__info__(:module)
    assert DogAPI.Retry.__info__(:struct) == nil
  end
end
