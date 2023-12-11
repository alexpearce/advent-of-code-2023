defmodule Solution do
  @space "."
  @galaxy "#"

  def part1 do
    input()
    |> apply_expansion()
    |> find_galaxies()
    |> pairs()
    |> Enum.map(&manhattan_distance/1)
    |> Enum.sum()
  end

  def part2 do
    input()
    nil
  end

  defp input do
    File.read!("11/input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end

  defp apply_expansion(lines) do
    lines
    |> expand_empty_lines()
    |> transpose()
    |> expand_empty_lines()
    |> transpose()
  end

  defp expand_empty_lines(lines) do
    Enum.reduce(lines, [], fn line, acc ->
      if Enum.all?(line, &Kernel.==(&1, @space)) do
        [line, line | acc]
      else
        [line | acc]
      end
    end)
  end

  defp transpose(lines) do
    lines
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  defp find_galaxies(lines) do
    for {line, row} <- Enum.with_index(lines),
        {character, column} <- Enum.with_index(line),
        character == @galaxy do
      {row, column}
    end
  end

  defp pairs(lst) do
    count = Enum.count(lst) - 1

    for x <- 0..count, y <- x..count, x != y do
      {Enum.at(lst, x), Enum.at(lst, y)}
    end
  end

  defp manhattan_distance({{x1, y1}, {x2, y2}}) do
    abs(x1 - x2) + abs(y1 - y2)
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
