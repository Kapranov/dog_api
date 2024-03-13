defmodule DogAPI.DSL.SparkQuizTest do
  use ExUnit.Case

  test "create a question" do
    defmodule Exam do
      use DogAPI.DSL.Spark

      quizzes do
        quiz "English end of the term exam", :essay do
          question "Jane Eyre, discuss."
          question "The Greate Gatsby, discuss."
        end
      end
    end

    _dsl_config = Exam.spark_dsl_config() |> dbg

    quizzes = Spark.Dsl.Extension.get_entities(Exam, [:quizzes])

    assert quizzes == [
      %DogAPI.DSL.Spark.Quiz{
        name: "English end of the term exam",
        type: :essay,
        questions: [
          %DogAPI.DSL.Spark.Question{
            title: "Jane Eyre, discuss."
          },
          %DogAPI.DSL.Spark.Question{
            title: "The Greate Gatsby, discuss."
          }
        ]
      }
    ]

    assert Enum.map_join(quizzes, &DogAPI.DSL.Spark.Quiz.introspect/1) ==
      """
      English end of the term exam (essay)

      Question(s):
      Jane Eyre, discuss.
      The Greate Gatsby, discuss.
      """
  end
end
