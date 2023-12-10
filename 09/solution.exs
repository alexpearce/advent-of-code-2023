defmodule Solution do
  def part1 do
    input()
    |> Enum.map(&compute_next_value/1)
    |> Enum.sum()
  end

  def part2 do
    input()
    nil
  end

  defp input do
    File.read!("09/input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split()
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp compute_next_value(values) do
    last_value = List.last(values)

    values
    |> do_compute([last_value])
    |> Enum.sum()
  end

  defp do_compute(values, last_values) do
    if Enum.all?(values, fn value -> value == 0 end) do
      last_values
    else
      [_head | tail] = values

      [last_value | _] =
        reduced =
        Enum.zip(values, tail)
        |> Enum.reduce([], fn {a, b}, lst -> [b - a | lst] end)

      last_values = [last_value | last_values]

      do_compute(Enum.reverse(reduced), last_values)
    end
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
