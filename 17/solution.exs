defmodule Solution do
  def part1 do
    grid = input()
    start = {0, 0}
    distances = dijkstra(grid, start)
    corner = Enum.max(Map.keys(distances))
    distances[corner]
  end

  def part2 do
    input()
    nil
  end

  defp input do
    grid =
      File.read!("17/input.txt")
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.graphemes/1)
      |> Enum.map(fn nums -> Enum.map(nums, &String.to_integer/1) end)

    for {line, row} <- Enum.with_index(grid), {num, col} <- Enum.with_index(line), into: %{} do
      {{row, col}, num}
    end
  end

  defp dijkstra(grid, start) do
    # Nodes to their distance from the start.
    visited = %{}
    # Nodes to their best-so-far distance from the start.
    tentative_distances = %{{start, :east, 0} => 0}

    grid
    |> explore(visited, tentative_distances)
    |> minimum_distances()
  end

  defp minimum_distances(visited) do
    for {{coord, _, _}, distance} <- visited, reduce: %{} do
      acc ->
        Map.update(acc, coord, distance, fn prev_distance ->
          if distance < prev_distance, do: distance, else: prev_distance
        end)
    end
  end

  defp explore(_grid, visited, tentative_distances) when tentative_distances == %{}, do: visited

  defp explore(grid, visited, tentative_distances) do
    {visiting, distance} =
      step =
      Enum.min_by(tentative_distances, fn {_, distance} -> distance end)

    {_, tentative_distances} =
      next_steps(grid, step)
      |> Enum.filter(fn {node, _} -> not Map.has_key?(visited, node) end)
      |> Enum.reduce(tentative_distances, fn step, acc ->
        {node, step_distance} = step

        Map.update(acc, node, step_distance, fn prev_distance ->
          if step_distance < prev_distance, do: step_distance, else: prev_distance
        end)
      end)
      |> Map.pop!(visiting)

    visited = Map.put(visited, visiting, distance)

    explore(grid, visited, tentative_distances)
  end

  defp next_steps(grid, step) do
    {node, _} = step

    headings(node)
    |> Enum.map(&apply_heading(&1, step))
    |> Enum.filter(fn {{coord, _, _}, _} -> Map.has_key?(grid, coord) end)
    |> Enum.map(&apply_score(&1, grid))
  end

  defp headings({_coord, dir, 3}), do: perpendicular_headings(dir)

  defp headings({_coord, dir, num_dir}), do: [{dir, num_dir + 1} | perpendicular_headings(dir)]

  defp perpendicular_headings(heading) when heading in [:north, :south],
    do: [{:east, 1}, {:west, 1}]

  defp perpendicular_headings(heading) when heading in [:east, :west],
    do: [{:north, 1}, {:south, 1}]

  defp apply_heading({dir, num_dir}, {{coord, _, _}, score}) do
    {{do_apply_heading(coord, dir), dir, num_dir}, score}
  end

  defp apply_score({{coord, _, _} = node, score}, grid) do
    {node, score + grid[coord]}
  end

  defp do_apply_heading({row, col}, :north), do: {row - 1, col}
  defp do_apply_heading({row, col}, :south), do: {row + 1, col}
  defp do_apply_heading({row, col}, :east), do: {row, col + 1}
  defp do_apply_heading({row, col}, :west), do: {row, col - 1}
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
