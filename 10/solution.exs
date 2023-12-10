defmodule Solution do
  @num_rows 140
  @num_cols 140

  def part1 do
    map = input()
    start = find_start(map)
    distances = explore(map, %{start => 0}, travel(start, :north), 0)

    halfway =
      Map.get(distances, travel(start, :west))
      |> Integer.floor_div(2)

    halfway + 1
  end

  def part2 do
    input()
    nil
  end

  defp input do
    File.read!("10/input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, row} ->
      for {character, col} <- Enum.with_index(String.graphemes(line)) do
        {{row, col}, character}
      end
    end)
    |> Enum.into(%{})
  end

  defp find_start(map) do
    {key, _value} = Enum.find(map, fn {_key, value} -> value == "S" end)

    key
  end

  defp explore(map, distances, coord, distance) do
    if Map.has_key?(distances, coord) do
      distances
    else
      to_here = distance + 1

      valid_neighbours(coord, map[coord])
      |> Enum.reduce(Map.put(distances, coord, to_here), fn neighbour, distances ->
        explore(map, distances, neighbour, to_here)
      end)
    end
  end

  defp valid_neighbours(coord, character) do
    character
    |> neighbours()
    |> Enum.reduce([], fn direction, acc ->
      dest = travel(coord, direction)
      if in_bounds(dest), do: [dest | acc], else: acc
    end)
  end

  defp neighbours("|"), do: [:north, :south]
  defp neighbours("-"), do: [:east, :west]
  defp neighbours("L"), do: [:north, :east]
  defp neighbours("J"), do: [:north, :west]
  defp neighbours("7"), do: [:south, :west]
  defp neighbours("F"), do: [:south, :east]
  defp neighbours("."), do: []
  defp neighbours("S"), do: []

  defp travel({row, col}, :north), do: {row - 1, col}
  defp travel({row, col}, :south), do: {row + 1, col}
  defp travel({row, col}, :west), do: {row, col - 1}
  defp travel({row, col}, :east), do: {row, col + 1}

  defp in_bounds({row, col}) do
    not (row < 0 or col < 0 or row >= @num_rows or col >= @num_cols)
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
