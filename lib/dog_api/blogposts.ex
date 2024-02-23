defmodule DogAPI.Blogposts do
  @moduledoc false

  alias DogAPI.Blogpost

  @spec get_page(page :: non_neg_integer()) :: Blogpost.t()
  def get_page(page \\ 1) do
    py_project_path = Path.join(File.cwd!(), "python")
    {:ok, python} = :python.start(python_path: String.to_charlist(py_project_path))

    {blogs, ""} =
      python
      |> :python.call(:curiosum_blogposts, :get_blog_page, [page])

    :python.stop(python)

    blogs
  end
end

defmodule DogAPI.Blogpost do
  @moduledoc false

  @name __MODULE__

  @enforce_keys [:title, :tags, :teaser, :author, :read_time, :posted_at]
  defstruct [:title, :tags, :teaser, :author, :read_time, :posted_at]

  @type t() :: %@name{
    title: String.t(),
    tags: [Map.new()],
    teaser: String.t(),
    author: Map.new(),
    read_time: Timex.Duration.t(),
    posted_at: Date.t()
  }
end
