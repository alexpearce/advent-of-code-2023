defmodule Solution do
  def part1 do
    input()
    nil
  end

  def part2 do
    input()
    nil
  end

  defp input do
    File.read!("00/input.txt")
    |> String.trim()
    |> String.split("\n")
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
