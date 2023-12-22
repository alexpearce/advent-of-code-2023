defmodule Solution do
  @line_regex ~r/(?<direction>[UDLR]) (?<distance>\d+) \(#(?<colour>[a-f0-9]+)\)/

  def part1 do
    start = {0, 0}

    # Create a map whose keys are the perimeter coordinates.
    dug =
      input()
      |> dig(start, %{start => true})

    # Find the rectangle which bounds the perimeter and explore all
    # non-perimeter coordinates reachable from that rectangle.
    bounds = bounds(dug)
    frontier = boundary_points(bounds)

    explore(dug, frontier, bounds)
    |> fill(bounds)
    |> count_filled()
  end

  def part2 do
    input()
    nil
  end

  defp input do
    File.read!("18/input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
  end

  defp bounds(dug) do
    rows = Enum.map(dug, fn {{row, _col}, _} -> row end)
    cols = Enum.map(dug, fn {{_row, col}, _} -> col end)

    {Enum.min_max(rows), Enum.min_max(cols)}
  end

  defp boundary_points(bounds) do
    {{min_row, max_row}, {min_col, max_col}} = bounds
    left = for row <- min_row..max_row, do: {row, min_col}
    right = for row <- min_row..max_row, do: {row, max_col}
    top = for col <- min_col..max_col, do: {min_row, col}
    bottom = for col <- min_col..max_col, do: {max_row, col}
    Enum.concat([left, right, top, bottom])
  end

  defp parse_line(line) do
    %{"colour" => colour, "direction" => direction, "distance" => distance} =
      Regex.named_captures(@line_regex, line)

    {direction, String.to_integer(distance, 10), String.to_integer(colour, 16)}
  end

  defp dig([], _from, dug), do: dug

  defp dig([step | plan], from, dug) do
    {direction, distance, _colour} = step
    {next, dug} = do_dig(from, direction_delta(direction), distance, dug)
    dig(plan, next, dug)
  end

  defp do_dig(from, _direction_delta, 0, dug), do: {from, dug}

  defp do_dig({row, col}, {d_row, d_col} = delta, distance, dug) do
    pos = {row + d_row, col + d_col}
    dug = Map.put(dug, pos, true)
    do_dig(pos, delta, distance - 1, dug)
  end

  defp direction_delta("U"), do: {-1, 0}
  defp direction_delta("D"), do: {1, 0}
  defp direction_delta("L"), do: {0, -1}
  defp direction_delta("R"), do: {0, 1}

  defp explore(dug, [], _bounds), do: dug

  defp explore(dug, [coord | frontier], bounds) do
    case dug[coord] do
      nil ->
        neighbours = neighbours(coord, bounds)
        dug = Map.put(dug, coord, false)
        explore(dug, neighbours ++ frontier, bounds)

      _value ->
        # Coord has been visited.
        explore(dug, frontier, bounds)
    end
  end

  defp neighbours({row, col}, {{min_row, max_row}, {min_col, max_col}}) do
    [
      {row - 1, col},
      {row + 1, col},
      {row, col - 1},
      {row, col + 1}
    ]
    |> Enum.filter(fn {row, col} ->
      min_row <= row and row <= max_row and min_col <= col and col <= max_col
    end)
  end

  defp fill(dug, bounds) do
    {{min_row, max_row}, {min_col, max_col}} = bounds

    for row <- min_row..max_row, col <- min_col..max_col, into: %{} do
      char = if dug[{row, col}] == false, do: ".", else: "#"
      {{row, col}, char}
    end
  end

  defp count_filled(dug) do
    Enum.count(dug, fn {_coord, character} -> character == "#" end)
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
