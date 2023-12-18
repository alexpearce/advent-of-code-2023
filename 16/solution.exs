defmodule Solution do
  @empty "."
  @vertical_splitter "|"
  @horizontal_splitter "-"
  @left_mirror "\\"
  @right_mirror "/"

  def part1 do
    input()
    |> traverse([{{0, 0}, :east}], %{})
    |> count_energized()
  end

  def part2 do
    input()
    nil
  end

  defp input do
    File.read!("16/input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, row} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {character, col} -> {{row, col}, character} end)
    end)
    |> Enum.into(%{})
  end

  defp traverse(_map, [], seen), do: seen

  defp traverse(map, [{{_row, _col} = coord, dir} = key | frontier], seen) do
    valid_cell? = not is_nil(Map.get(map, coord, nil))
    visited? = Map.get(seen, key, false)
    visit? = valid_cell? and not visited?

    if visit? do
      neighbours = to_visit(map, coord, dir)
      seen = Map.put(seen, key, true)
      traverse(map, neighbours ++ frontier, seen)
    else
      traverse(map, frontier, seen)
    end
  end

  defp to_visit(map, coord, dir) do
    next_steps(map[coord], coord, dir)
  end

  defp next_steps(@empty, {row, col}, :north), do: [{{row - 1, col}, :north}]
  defp next_steps(@empty, {row, col}, :south), do: [{{row + 1, col}, :south}]
  defp next_steps(@empty, {row, col}, :east), do: [{{row, col + 1}, :east}]
  defp next_steps(@empty, {row, col}, :west), do: [{{row, col - 1}, :west}]

  defp next_steps(@vertical_splitter, {row, col}, dir) when dir in [:east, :west],
    do: [{{row - 1, col}, :north}, {{row + 1, col}, :south}]

  defp next_steps(@vertical_splitter, coord, dir), do: next_steps(@empty, coord, dir)

  defp next_steps(@horizontal_splitter, {row, col}, dir) when dir in [:north, :south],
    do: [{{row, col + 1}, :east}, {{row, col - 1}, :west}]

  defp next_steps(@horizontal_splitter, coord, dir), do: next_steps(@empty, coord, dir)

  defp next_steps(@left_mirror, {row, col}, :north), do: [{{row, col - 1}, :west}]
  defp next_steps(@left_mirror, {row, col}, :south), do: [{{row, col + 1}, :east}]
  defp next_steps(@left_mirror, {row, col}, :east), do: [{{row + 1, col}, :south}]
  defp next_steps(@left_mirror, {row, col}, :west), do: [{{row - 1, col}, :north}]

  defp next_steps(@right_mirror, {row, col}, :north), do: [{{row, col + 1}, :east}]
  defp next_steps(@right_mirror, {row, col}, :south), do: [{{row, col - 1}, :west}]
  defp next_steps(@right_mirror, {row, col}, :east), do: [{{row - 1, col}, :north}]
  defp next_steps(@right_mirror, {row, col}, :west), do: [{{row + 1, col}, :south}]

  defp count_energized(traversals) do
    traversals
    |> Enum.map(fn {{coord, _dir}, true} -> {coord, true} end)
    |> Enum.into(%{})
    |> Enum.count()
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
