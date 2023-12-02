defmodule Solution do
  @game_re ~r/Game (\d+)/
  @red_re ~r/(\d+) red/
  @green_re ~r/(\d+) green/
  @blue_re ~r/(\d+) blue/

  def part1 do
    input()
    |> Enum.map(&extract/1)
    |> Enum.map(&aggregate_counts/1)
    |> Enum.filter(fn data -> valid_game?(data, red: 12, green: 13, blue: 14) end)
    |> Enum.map(fn %{game_id: game_id} -> game_id end)
    |> Enum.sum()
  end

  def part2 do
    input()
    nil
  end

  defp input do
    File.read!("02/input.txt")
    |> String.trim()
    |> String.split("\n")
  end

  defp extract(line) do
    [_, game_id] = Regex.run(@game_re, line)
    game_id = String.to_integer(game_id)

    red_counts =
      @red_re
      |> Regex.scan(line)
      |> Enum.map(fn [_, count] -> String.to_integer(count) end)

    green_counts =
      @green_re
      |> Regex.scan(line)
      |> Enum.map(fn [_, count] -> String.to_integer(count) end)

    blue_counts =
      @blue_re
      |> Regex.scan(line)
      |> Enum.map(fn [_, count] -> String.to_integer(count) end)

    %{
      game_id: game_id,
      blue_counts: blue_counts,
      red_counts: red_counts,
      green_counts: green_counts
    }
  end

  defp aggregate_counts(data) do
    %{
      data
      | red_counts: Enum.max(data.red_counts),
        green_counts: Enum.max(data.green_counts),
        blue_counts: Enum.max(data.blue_counts)
    }
  end

  defp valid_game?(data, red: max_red, green: max_green, blue: max_blue) do
    data.red_counts <= max_red &&
      data.green_counts <= max_green &&
      data.blue_counts <= max_blue
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
