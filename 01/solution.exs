defmodule Solution do
  @digits 0..9 |> Enum.map(fn i -> "#{i}" end) |> MapSet.new()

  def part1 do
    File.read!("01/input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&extract_digits/1)
    |> Enum.map(&combine_digits/1)
    |> Enum.map(&parse_integer/1)
    |> Enum.sum()
  end

  defp extract_digits(line) do
    line
    |> String.graphemes()
    |> Enum.filter(fn character -> MapSet.member?(@digits, character) end)
  end

  defp combine_digits(digits) do
    first = List.first(digits)
    last = List.last(digits)
    first <> last
  end

  defp parse_integer(s) do
    {integer, _} = Integer.parse(s)
    integer
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")
