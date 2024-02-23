defmodule DogAPI.Tracing do
  @moduledoc """
  """

  require OpenTelemetry.Tracer

  defguard is_set(value) when is_map(value) or is_list(value) or is_tuple(value)

  defmacro __using__(_opts) do
    quote do
      require OpenTelemetry.Tracer

      require unquote(__MODULE__)
      import unquote(__MODULE__), only: [span: 1, span: 2, span: 3]
    end
  end

  def set_attribute(key, value) when is_set(value) do
    set_attributes(key, value)
  end

  def set_attribute(key, value) do
    OpenTelemetry.Tracer.set_attribute(key, value)
  end

  def set_attributes(key, values) do
    key
    |> enumerable_to_attrs(values)
    |> OpenTelemetry.Tracer.set_attributes()
  end

  defp enumerable_to_attrs(name, enumerable)

  defp enumerable_to_attrs(name, s) when is_struct(s) do
    enumerable_to_attrs(name, Map.from_struct(s))
  end

  defp enumerable_to_attrs(name, enumerable) when is_map(enumerable) or is_list(enumerable) do
    enumerable
    |> Enum.with_index()
    |> Map.new(fn
      {{key, _value} = item, index} when is_set(key) ->
        {"#{name}.#{index}", inspect(item)}
      {{key, value}, _index} ->
        {"#{name}.#{key}", inspect(value)}
      {value, index} ->
        {"#{name}.#{index}", inspect(value)}
    end)
  end

  defp enumerable_to_attrs(name, enumerable) when is_tuple(enumerable) do
    enumerable_to_attrs(name, Tuple.to_list(enumerable))
  end
end
