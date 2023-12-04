defmodule Solution do
  @line_regex ~r/Card\s+(?:\d+): (.*) \| (.*)/

  def part1 do
    input()
    |> Enum.map(&parse/1)
    |> Enum.map(&intersection/1)
    |> Enum.map(&tally/1)
    |> Enum.sum()
  end

  def part2 do
    input()
    nil
  end

  defp input do
    File.read!("04/input.txt")
    |> String.trim()
    |> String.split("\n")
  end

  defp parse(line) do
    [_match, winning, held] = Regex.run(@line_regex, line)
    {parse_numbers(winning), parse_numbers(held)}
  end

  defp parse_numbers(numbers) do
    numbers
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end

  defp intersection({winning, held}) do
    MapSet.intersection(
      MapSet.new(winning),
      MapSet.new(held)
    )
  end

  defp tally(intersection) do
    count = MapSet.size(intersection)

    if count == 0, do: 0, else: 2 ** (count - 1)
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
