defmodule Encode do
  @alphabet "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
  @length String.length(@alphabet)
  def call(input, acc \\ "")
  def call(0, acc), do: acc

  def call(input, acc) when is_binary(input) do
    bindecoded = :binary.decode_unsigned(input)
    getcall = call(bindecoded, acc)
    prepended = addzeros(getcall, input)
    prepended
  end

  def call(input, acc) do
    division = div(input, @length)
    callval = call(division, exhash(input, acc))
    callval
  end

  defp exhash(input, acc) do
    "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    |> String.at(rem(input, @length))
    |> Kernel.<>(acc)
  end

  defp addzeros(acc, input) do
    codezeros(input)
    |> Kernel.<>(acc)
  end

  defp codezeros(input) do
    leadz = leadzeros(input)
    codez = dupzeros(leadz)
    codez
  end

  defp leadzeros(input) do
    bintolist = :binary.bin_to_list(input)
    leadz = Enum.find_index(bintolist, &(&1 != 0))
    leadz
  end

  defp dupzeros(count) do
    first = String.first(@alphabet)
    return = String.duplicate(first, count)
    return
  end
end
