defmodule Solution do
  def part1 do
    input()
    |> parse()
    |> Enum.zip()
    |> Enum.map(&compute_race_spread/1)
    |> Enum.map(&Enum.count/1)
    |> Enum.reduce(1, &Kernel.*/2)
  end

  def part2 do
    [time, distance] =
      input()
      |> parse_bad_kerning()

    compute_race_spread({time, distance})
    |> Enum.count()
  end

  defp input do
    File.read!("06/input.txt")
    |> String.trim()
    |> String.split("\n")
  end

  defp parse([times_line, distances_line]) do
    [parse_line(times_line), parse_line(distances_line)]
  end

  defp parse_line(line) do
    [_ | numbers] = String.split(line)
    Enum.map(numbers, &String.to_integer/1)
  end

  defp compute_race_spread({time, target_distance}) do
    for button_press_duration <- 0..time do
      speed = button_press_duration
      remaining_time = time - button_press_duration
      remaining_time * speed
    end
    |> Enum.filter(fn distance -> distance > target_distance end)
  end

  defp parse_bad_kerning([times_line, distances_line]) do
    [parse_line_bad_kerning(times_line), parse_line_bad_kerning(distances_line)]
  end

  defp parse_line_bad_kerning(line) do
    [_ | numbers] = String.split(line)

    numbers
    |> Enum.join("")
    |> String.to_integer()
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
