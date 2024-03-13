defmodule DogAPI.DSL.CmdThing.LinuxInstance do
  @moduledoc false

  @linux_instance_command %Spark.Dsl.Section{
    name: :linux_instance_command,
    schema: [
      command: [
        type: {:list, :string},
        doc: "The command to run"
      ],
      args: [
        type: {:list, :string},
        doc: "The arguments to pass to the command"
      ],
      opts: [
        type: {:list, :string},
        doc: "The options to pass to the command"
      ]
    ]
  }

  use Spark.Dsl.Extension, sections: [@linux_instance_command]
end
