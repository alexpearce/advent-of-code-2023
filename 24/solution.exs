defmodule Solution do
  @xy_intersection_min 200_000_000_000_000
  @xy_intersection_max 400_000_000_000_000

  def part1 do
    hailstones =
      input()
      |> Enum.with_index()

    for {h1, x} <- hailstones, {h2, y} <- hailstones do
      if x <= y, do: false, else: intersection?(h1, h2)
    end
    |> Enum.count(& &1)
  end

  def part2 do
    input()
    nil
  end

  defp input do
    File.read!("24/input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    line
    |> String.replace(" ", "")
    |> String.split("@")
    |> Enum.map(&parse_numbers/1)
  end

  defp parse_numbers(s) do
    s
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp intersection?(h1, h2) do
    [[px1, py1, _pz1], [vx1, vy1, _vz1]] = h1
    [[px2, py2, _pz2], [vx2, vy2, _vz2]] = h2

    # Define each trajectory as a vector equation:
    #
    # [x(t), y(t)] = [v_x * t + p_x, v_y * t + p_y].
    #
    # Because we don't require the lines to intersect at the same time,
    # we can require equality of the two vector equations:
    #
    # [x_1(t1), y_1(t1)] = [x_2(t2), y_2(t2)]
    #
    # and solve for the two unknowns t1 and t2.
    #
    # We have a valid intersection if t1 and t2 are both greater than zero,
    # and if the resulting x and y values are within the test range.
    {t1, t2} =
      try do
        t2 = (vy1 / vx1 * (px2 - px1) + py1 - py2) / (vy2 - vy1 * vx2 / vx1)
        t1 = (vx2 * t2 + px2 - px1) / vx1
        {t1, t2}
      rescue
        ArithmeticError -> {-1, -1}
      end

    x = vx1 * t1 + px1
    y = vy1 * t1 + py1

    valid_intersection?(x, y, t1, t2)
  end

  defp valid_intersection?(x, y, t1, t2) do
    future? = t1 >= 0 and t2 >= 0
    x_within_range? = @xy_intersection_min <= x and x <= @xy_intersection_max
    y_within_range? = @xy_intersection_min <= y and y <= @xy_intersection_max
    future? and x_within_range? and y_within_range?
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
