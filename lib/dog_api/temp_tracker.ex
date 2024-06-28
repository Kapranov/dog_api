defmodule DogAPI.TempTracker do
  @moduledoc """
  """

  use Agent

  @name __MODULE__

  def start_link(_), do: Agent.start_link(fn -> nil end, name: @name)

  def get_coldest_city(val \\ "C") do
    if String.contains?(val, "C") do
      Agent.get(@name, fn {city, country, temp} ->
        "The coldest city on earth is currently #{city}, #{country} with a temperature of #{kelvin_to_c(temp)}°C"
      end)
    else
      Agent.get(@name, fn {city, country, temp} ->
        "The coldest city on earth is currently #{city}, #{country} with a temperature of #{kelvin_to_f(temp)}°F"
      end)
    end
  end

  def update_coldest_city(:error), do: nil

  def update_coldest_city({_, _, new_temp} = new_data) do
    Agent.update(@name, fn
      {_, _, orig_temp} = orig_data ->
        if new_temp < orig_temp, do: new_data, else: orig_data
      nil ->
        new_data
    end)
  end

  defp kelvin_to_c(kelvin), do: (kelvin - 273.15)
  defp kelvin_to_f(kelvin), do: (kelvin - 273.15) * 9/5 + 32
end
