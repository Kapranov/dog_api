defmodule DogAPI.EthSync.Infura do
  @moduledoc false

  @doc """
  Get an entire block.

  ## Examples.

      iex> DogAPI.EthSync.Infura.get_block(1)
      {:ok, %{"number" => "0x1", "transactions" => []}}

  """
  def get_block(num) do
    {:ok,
      %{
        "number" => to_hex(num),
        "transactions" => []
      }
    }
  end

  defp to_hex(decimal), do: "0x" <> Integer.to_string(decimal, 16)
end
