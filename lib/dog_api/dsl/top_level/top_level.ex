defmodule DogAPI.DSL.TopLevel do
  @moduledoc false

  defmodule Dsl do
    @moduledoc false

    @atom %Spark.Dsl.Entity{
      name: :atom,
      target: DogAPI.DSL.Recursive.Atom,
      args: [:name],
      schema: [
        name: [
          type: :atom,
          required: true
        ]
      ]
    }

    @step %Spark.Dsl.Entity{
      name: :step,
      target: DogAPI.DSL.Recursive.Step,
      args: [:name],
      recursive_as: :steps,
      entities: [ steps: [] ],
      schema: [
        name: [
          type: :atom,
          required: true
        ],
        number: [
          type: :integer
        ]
      ]
    }

    @special_step %Spark.Dsl.Entity{
      name: :special_step,
      target: DogAPI.DSL.Recursive.Step,
      args: [:name],
      recursive_as: :steps,
      entities: [ steps: [] ],
      schema: [
        name: [
          type: :atom,
          required: true
        ],
        number: [
          type: :integer
        ]
      ]
    }

    @nested_section %Spark.Dsl.Section{
      name: :nested_section,
      schema: [
        bar: [
          type: :integer,
          doc: "Some documentation"
        ]
      ]
    }

    @steps %Spark.Dsl.Section{
      name: :steps,
      top_level?: true,
      sections: [@nested_section],
      schema: [
        foo: [
          type: :integer,
          doc: "Some documentation"
        ]
      ],
      entities: [@step, @special_step, @atom]
    }

    use Spark.Dsl.Extension, sections: [@steps]
  end

  use Spark.Dsl, default_extensions: [extensions: Dsl]
end
