defmodule DogAPI.DSL.Spark do
  @moduledoc """
  The `SparkQuiz` DSL.

  ## Example.

  ```
  quiz: "English end of term exam", :essay do
    question "Jane Eyre, discuss."
  end

  quiz "Math Pop Quiz", :combo do
    question "1 + 1", "2"
    multi_choice_question "3 * 9" do
      answer :a,
      choice :a, "2"
      choice :b, "27"
      choice :c, "19"
      choice :d, "2"
    end
  end
  ```
  """

  defmodule Quiz do
    defstruct [:name, :type, :questions]

    #@spec introspect(atom() | %{:name => any(), :questions => any(), :type => any(), optional(any())}) :: any()
    @spec introspect(atom() | %{:name => any(), :questions => any(), :type => any()}) :: any()
    def introspect(quiz) do
      """
      #{quiz.name} (#{quiz.type})

      Question(s):
      #{Enum.map_join(quiz.questions, "\n", & &1.title)}
      """
    end
  end

  defmodule Question do
    defstruct [:title]
  end

  defmodule Dsl do
    @question %Spark.Dsl.Entity{
      name: :question,
      describe: "Define a question in a quiz",
      examples: [
        "question \"Why now?\""
      ],
      target: Question,
      args: [:title],
      schema: [
        title: [
          type: :string,
          required: true,
          doc: "The question itself"
        ]
      ]
    }

    @quiz %Spark.Dsl.Entity{
      name: :quiz,
      describe: "Define a quiz with questions",
      examples: [
        "quiz \"Pop quiz!\", :multiple_choice"
      ],
      target: Quiz,
      args: [:name, :type],
      entities: [questions: [@question]],
      schema: [
        name: [
          type: :string,
          required: true,
          doc: "The quiz title"
        ],
        type: [
          type: :atom,
          required: true,
          doc: "The type of quiz"
        ]
      ]
    }

    @toplevel_section %Spark.Dsl.Section{
      name: :quizzes,
      entities: [@quiz]
    }

    use Spark.Dsl.Extension, sections: [@toplevel_section]
  end

  use Spark.Dsl, default_extensions: [extensions: [Dsl]]
end
