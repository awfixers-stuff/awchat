defmodule Gateway.Base32 do
  @moduledoc false
  import Bitwise
  @alphabet ~c"ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"

  @spec encode(binary()) :: binary()
  def encode(<<>>), do: ""

  def encode(data) when is_binary(data) do
    do_encode(:binary.bin_to_list(data), 0, 0, [])
    |> IO.iodata_to_binary()
  end

  defp do_encode([], _buffer, _bits, acc), do: Enum.reverse(acc)

  defp do_encode([byte | rest], buffer, bits, acc) do
    buffer = (buffer <<< 8) + byte
    bits = bits + 8
    do_encode_emit(rest, buffer, bits, acc)
  end

  defp do_encode_emit(data, buffer, bits, acc) when bits >= 5 do
    index = (buffer >>> (bits - 5)) &&& 0x1F
    bits = bits - 5
    do_encode_emit(data, buffer, bits, [Enum.at(@alphabet, index) | acc])
  end

  defp do_encode_emit([], buffer, bits, acc) when bits > 0 do
    index = (buffer <<< (5 - bits)) &&& 0x1F
    Enum.reverse([Enum.at(@alphabet, index) | acc])
    |> IO.iodata_to_binary()
  end

  defp do_encode_emit([], _buffer, _bits, acc), do: Enum.reverse(acc)

  defp do_encode_emit(data, buffer, bits, acc) do
    do_encode(data, buffer, bits, acc)
  end
end