defmodule DogAPI.DSL.MyCmd do
  @moduledoc false

  use DogAPI.DSL.CmdThing, extensions: [DogAPI.DSL.CmdThing.LinuxInstance]

  linux_instance_command do
    command(["foo", "bar"])
    args(["arg1", "arg2"])
    opts(["option1", "option2"])
  end
end
