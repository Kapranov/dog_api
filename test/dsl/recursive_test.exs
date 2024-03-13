defmodule DogAPI.DSL.RecursiveTest do
  use ExUnit.Case

  alias DogAPI.DSL.{
    Recursive.Atom,
    Recursive.Step,
    TopLevel.Info
  }

  test "recursive DSLs can be defined without recursive elements" do
    defmodule Simple do
      use DogAPI.DSL.Recursive

      steps do
        step(:foo)
      end
    end

    assert [%Step{name: :foo, steps: []}] = Info.steps(Simple)
  end

  test "recursive DSLs can recurse" do
    defmodule OneRecurse do
      use DogAPI.DSL.Recursive

      steps do
        step :foo do
          step(:bar)
        end
      end
    end

    assert [
      %Step{
        name: :foo,
        steps: [ %Step{name: :bar, steps: []} ]
      }
    ] = Info.steps(OneRecurse)
  end

  test "recursive DSLs can be mixed" do
    defmodule MixedRecurse do
      use DogAPI.DSL.Recursive

      steps do
        step :foo do
          special_step(:special)
          atom(:bar)
        end
      end
    end

    assert [
      %Step{
        name: :foo,
        steps: [
          %Step{name: :special, steps: []},
          %Atom{name: :bar}
        ]
      }
    ] = Info.steps(MixedRecurse)
  end

  test "recursive DSLs that share entities don't collide" do
    defmodule MixedRecurseSharedEntity do
      use DogAPI.DSL.Recursive

      steps do
        step :foo do
          special_step(:special) do
            atom(:bar)
          end

          atom(:bar)
        end
      end
    end

    assert [
      %Step{
        name: :foo,
        steps: [
          %Step{
            name: :special,
            steps: [
              %Atom{name: :bar}
            ]
          },
          %Atom{name: :bar}
        ]
      }
    ] = Info.steps(MixedRecurseSharedEntity)
  end

  test "recursive DSLs that share options don't collide" do
    defmodule OptionsDontCollide do
      use DogAPI.DSL.Recursive

      steps do
        step :foo do
          number(10)

          special_step(:special) do
            number(12)
          end
        end
      end
    end

    assert [
      %Step{
        name: :foo,
        number: 10,
        steps: [
          %Step{
            name: :special,
            number: 12
          }
        ]
      }
    ] = Info.steps(OptionsDontCollide)
  end

  test "recursive DSLs can share entities and be deeply nested" do
    defmodule DeeplyNested do
      use DogAPI.DSL.Recursive

      steps do
        step :foo do
          special_step(:special) do
            atom(:bar)

            step :step_in_special do
              step :step_in_special2 do
                atom(:bar)
              end
            end
          end

          step :not_special do
            special_step(:special2) do
              atom(:bar)
            end
          end
        end
      end
    end

    assert [
      %Step{
        name: :foo,
        steps: [
          %Step{
            name: :special,
            steps: [
              %Atom{name: :bar},
              %Step{
                name: :step_in_special,
                steps: [
                  %Step{
                    name: :step_in_special2,
                    steps: [ %Atom{name: :bar} ]
                  }
                ]
              }
            ]
          },
          %Step{
            name: :not_special,
            steps: [
              %Step{
                name: :special2,
                steps: [ %Atom{name: :bar} ]
              }
            ]
          }
        ]
      }
    ] = Info.steps(DeeplyNested)
  end
end
