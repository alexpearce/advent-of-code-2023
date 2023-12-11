defmodule Solution do
  @space "."
  @galaxy "#"

  def part1 do
    solve(input(), 2)
  end

  def part2 do
    solve(input(), 1_000_000)
  end

  defp input do
    File.read!("11/input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end

  defp solve(lines, expansion_factor) do
    empty_rows = find_empty(lines)
    empty_columns = find_empty(transpose(lines))

    lines
    |> find_galaxies()
    |> pairs()
    |> Enum.map(
      &manhattan_distance_with_expansion(&1, empty_rows, empty_columns, expansion_factor)
    )
    |> Enum.sum()
  end

  defp find_empty(lines) do
    lines
    |> Enum.with_index()
    |> Enum.map(fn {line, index} ->
      empty? = Enum.all?(line, &Kernel.==(&1, @space))
      {index, empty?}
    end)
    |> Enum.into(%{})
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

  defp manhattan_distance_with_expansion(
         {{x1, y1}, {x2, y2}},
         empty_rows,
         empty_columns,
         expansion_factor
       ) do
    x =
      for x <- range(x1, x2), reduce: 0 do
        acc ->
          distance = if empty_rows[x], do: expansion_factor, else: 1
          acc + distance
      end

    y =
      for y <- range(y1, y2), reduce: 0 do
        acc ->
          distance = if empty_columns[y], do: expansion_factor, else: 1
          acc + distance
      end

    x + y
  end

  defp range(a, b) when a == b, do: []

  defp range(a, b) when a > b, do: range(b, a)

  defp range(a, b) do
    a..(b - 1)
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
