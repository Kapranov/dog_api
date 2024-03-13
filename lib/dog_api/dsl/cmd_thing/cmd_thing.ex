defmodule DogAPI.DSL.CmdThing do
  @moduledoc false

  use Spark.Dsl

  def thing(module) do
    module
    |> DogAPI.DSL.CmdThing.Info.linux_instance_command_command!()
    |> Enum.join(" ")
  end
end
