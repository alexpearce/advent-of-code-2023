defmodule Solution do
  def part1 do
    bricks =
      input()
      |> sort_by_z()
      |> settle()

    bricks
    |> Enum.with_index()
    |> Enum.filter(fn {_brick, index} ->
      bricks
      |> List.delete_at(index)
      |> stable?()
    end)
    |> Enum.count()
  end

  def part2 do
    input()
    nil
  end

  defp input do
    File.read!("22/input.txt")
    |> String.trim()
    |> String.split("\n")
    |> parse_lines()
  end

  defp parse_lines([]), do: []

  defp parse_lines([line | lines]) do
    [parse_line(line) | parse_lines(lines)]
  end

  defp parse_line(line) do
    [left, right] = String.split(line, "~")
    [parse_end(left), parse_end(right)]
  end

  defp parse_end(s) do
    s
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp sort_by_z(bricks) do
    # Each brick is re-defined by ends of increasing z, and then all bricks are
    # ordered by increasing z of their lowest-z end.
    bricks
    |> Enum.map(fn ends ->
      Enum.sort_by(ends, fn [x, y, z] -> {z, x, y} end)
    end)
    |> Enum.sort_by(fn [[x, y, z], _] -> {z, x, y} end)
  end

  defp settle(bricks) do
    {dropped_bricks, _} =
      Enum.reduce(bricks, {[], %{}}, fn brick, {dropped_bricks, height_map} ->
        {dropped_brick, height_map} = drop(brick, height_map)

        {[dropped_brick | dropped_bricks], height_map}
      end)

    dropped_bricks |> sort_by_z()
  end

  defp drop(brick, height_map) do
    coords = footprint(brick)

    # The brick will rest one level above the highest point on the height map
    # which overlaps with its xy footprint.
    new_z1 =
      coords
      |> Enum.map(&(1 + Map.get(height_map, &1, 0)))
      |> Enum.max()

    dropped_brick = drop_brick(brick, new_z1)
    new_z2 = new_z1 + brick_height(dropped_brick)

    height_map = Enum.reduce(coords, height_map, &Map.put(&2, &1, new_z2))

    {dropped_brick, height_map}
  end

  defp footprint(brick) do
    [[x1, y1, _], [x2, y2, _]] = brick
    for x <- x1..x2, y <- y1..y2, do: {x, y}
  end

  defp drop_brick(brick, z) do
    [[x1, y1, z1], [x2, y2, z2]] = brick
    [[x1, y1, z], [x2, y2, z + (z2 - z1)]]
  end

  defp brick_height(brick) do
    [[_, _, z1], [_, _, z2]] = brick
    z2 - z1
  end

  defp stable?(bricks) do
    {result, _} =
      Enum.reduce_while(bricks, {true, %{}}, fn brick, {_, height_map} ->
        {dropped_brick, height_map} = drop(brick, height_map)

        if dropped_brick == brick do
          {:cont, {true, height_map}}
        else
          {:halt, {false, nil}}
        end
      end)

    result
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
