defmodule DogAPI.DSL.TopLevelTest do
  use ExUnit.Case

  alias DogAPI.DSL.{
    Recursive.Step,
    TopLevel.Info
  }

  test "top level DSL entities are available" do
    defmodule Simple do
      use DogAPI.DSL.TopLevel

      foo(10)

      step :foo do
        step(:bar)
      end
    end

    assert [%Step{name: :foo, steps: [%Step{}]}] = Info.steps(Simple)
    assert {:ok, 10} = Info.steps_foo(Simple)
  end

  test "nested DSL sections are available" do
    defmodule Nested do
      use DogAPI.DSL.TopLevel

      nested_section do
        bar(20)
      end

      foo(10)

      step :foo do
        step(:bar)
      end
    end

    assert [%Step{name: :foo, steps: [%Step{}]}] = Info.steps(Nested)
    assert {:ok, 10} = Info.steps_foo(Nested)
    assert {:ok, 20} = Info.steps_nested_section_bar(Nested)
  end
end
