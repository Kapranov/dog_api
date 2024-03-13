defmodule DogAPI.DSL.CmdThing.Info do
  @moduledoc false

  use Spark.InfoGenerator,
    extension: DogAPI.DSL.CmdThing.LinuxInstance,
    sections: [:linux_instance_command]
end
