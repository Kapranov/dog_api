defmodule DogAPI.DSL.Contact.TedDansen do
  @moduledoc "Some text ..."

  use DogAPI.DSL.Contact, fragments: [DogAPI.DSL.Contact.TedDansenFragment]

  alias Foo.Bar, as: Bar
  alias Foo.Bar, as: Buz

  contact do
    module(Bar.Baz)
    module(Buz)
  end

  personal_details do
    first_name("Ted")
    last_name("Dansen")
  end
end
