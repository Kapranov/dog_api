defmodule DogAPI.FeatureSimpleTest do
  use ExUnit.Case

  describe "Scenarios can provide custom timeout" do
    test "scenario that takes too long stops executing" do
      defmodule FeatureTimeoutTest do
        use Cabbage.Feature, file: "simple.feature"

        defthen ~r/^I provide Given$/, _vars, _state do
          Process.sleep(:infinity)
        end

        defgiven ~r/^I provide And$/, _vars, _state do
          Process.sleep(:infinity)
        end

        defgiven ~r/^I provide When$/, _vars, _state do
          Process.sleep(:infinity)
        end

        defgiven ~r/^I provide Then$/, _vars, _state do
          Process.sleep(:infinity)
        end
      end
    end
  end
end
