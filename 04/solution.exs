defmodule Solution do
  @line_regex ~r/Card\s+(?:\d+): (.*) \| (.*)/

  def part1 do
    input()
    |> Enum.map(&parse/1)
    |> Enum.map(&intersection_size/1)
    |> Enum.map(&tally/1)
    |> Enum.sum()
  end

  def part2 do
    input()
    |> Enum.map(&parse/1)
    |> Enum.map(&intersection_size/1)
    |> add_won_scratchcards()
    |> Enum.map(fn {_key, value} -> value end)
    |> Enum.sum()
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

  defp intersection_size({winning, held}) do
    MapSet.intersection(
      MapSet.new(winning),
      MapSet.new(held)
    )
    |> MapSet.size()
  end

  defp tally(0), do: 0

  defp tally(intersection_size), do: 2 ** (intersection_size - 1)

  defp add_won_scratchcards(intersection_sizes) do
    intersection_sizes
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {card_intersection_size, index}, acc ->
      acc = Map.put_new(acc, index, 1)

      if card_intersection_size > 0 do
        Enum.reduce(1..card_intersection_size, acc, fn offset, acc ->
          Map.update(acc, index + offset, 1 + acc[index], fn value -> value + acc[index] end)
        end)
      else
        acc
      end
    end)
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
