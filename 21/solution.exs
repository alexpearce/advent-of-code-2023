defmodule Solution do
  @rock "#"
  @start "S"

  def part1 do
    map = input()
    start = find_start(map)

    Enum.reduce(1..64, [start], fn _index, frontier ->
      # All gardens reachable in one step from any frontier coord.
      for coord <- frontier, neighbour <- neighbours(map, coord), into: MapSet.new() do
        neighbour
      end
    end)
    |> MapSet.size()
  end

  def part2 do
    input()
    nil
  end

  defp input do
    lines =
      File.read!("21/input.txt")
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.graphemes/1)

    for {line, row} <- Enum.with_index(lines),
        {character, col} <- Enum.with_index(line),
        into: %{} do
      {{row, col}, character}
    end
  end

  defp find_start(map) do
    [{coord, _character}] = Enum.filter(map, fn {_coord, value} -> value == @start end)
    coord
  end

  defp neighbours(map, coord) do
    {row, col} = coord

    [
      {row - 1, col},
      {row + 1, col},
      {row, col - 1},
      {row, col + 1}
    ]
    |> Enum.filter(&(Map.get(map, &1, @rock) != @rock))
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
