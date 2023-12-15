defmodule Solution do
  def part1 do
    input()
    |> Enum.map(&hash/1)
    |> Enum.sum()
  end

  def part2 do
    input()
    nil
  end

  defp input do
    File.read!("15/input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.join()
    |> String.split(",")
  end

  defp hash(s) do
    s
    |> String.to_charlist()
    |> Enum.reduce(0, fn codepoint, acc ->
      acc = acc + codepoint
      acc = 17 * acc
      rem(acc, 256)
    end)
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
