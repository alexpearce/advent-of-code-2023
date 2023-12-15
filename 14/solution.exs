defmodule Solution do
  @round "O"
  @cube "#"
  @empty "."

  def part1 do
    input()
    |> tilt_platform(:north)
    |> score()
  end

  def part2 do
    platform = input()

    cache = %{platform => 0}

    # After manual inspection of the scores after each cycle, it appears that
    # there is a cycle, or continuous loop, within the scores. That is after an
    # initial number of platform cycles, the score progresses through the same
    # series of values infinitely.
    #
    # This presumably means the same platform configurations keep appearing. We
    # will find the initial number of platform cycles before entering the loop
    # as well as the length of loop, which is the number of platform cycles after
    # entering the loop until we reach the same platform configuration.
    {cycle_start, cycle_end} =
      Enum.reduce_while(1..1_000, {platform, cache}, fn index, {prev_platform, cache} ->
        cycled_platform = cycle_platform(prev_platform)

        case Map.get(cache, cycled_platform) do
          nil ->
            {:cont, {cycled_platform, Map.put(cache, cycled_platform, index)}}

          prev_index ->
            {:halt, {prev_index, index}}
        end
      end)

    # The cycle length is the number of iterations between entering the loop and
    # revisiting the loop start.
    cycle_length = cycle_end - cycle_start
    # Once we have entered the loop, we have this many steps left going round
    # and round until we reach the 1-billion-iteration target.
    steps_in_cycle = 1_000_000_000 - cycle_start
    # But because we have a loop, we don't need to repeat the computation
    # `steps_in_cycle` times; we can just compute the offset into the loop we'd
    # be after a billion iterations and compute up to that offset.
    steps_left_in_cycle = rem(steps_in_cycle, cycle_length)
    total_steps = cycle_start + steps_left_in_cycle

    # Iterate through cycles up to the loop offset. There's no need to keep
    # going after this, as we'll end up at the same platform configuration after
    # 1 billion iterations.
    Enum.reduce(1..total_steps, platform, fn _index, prev_platform ->
      cycle_platform(prev_platform)
    end)
    |> score()
  end

  defp input do
    File.read!("14/input.txt")
    # File.read!("14/example.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end

  defp cycle_platform(lines) do
    lines
    |> tilt_platform(:north)
    |> tilt_platform(:west)
    |> tilt_platform(:south)
    |> tilt_platform(:east)
  end

  defp tilt_platform(lines, :north) do
    lines
    |> transpose()
    |> Enum.map(&shift_rocks/1)
    |> transpose()
  end

  defp tilt_platform(lines, :south) do
    lines
    |> transpose()
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(&shift_rocks/1)
    |> Enum.map(&Enum.reverse/1)
    |> transpose()
  end

  defp tilt_platform(lines, :east) do
    lines
    |> Enum.map(&Enum.reverse/1)
    |> tilt_platform(:west)
    |> Enum.map(&Enum.reverse/1)
  end

  defp tilt_platform(lines, :west) do
    Enum.map(lines, &shift_rocks/1)
  end

  defp shift_rocks(line) do
    {buffer, num_empty} =
      line
      |> Enum.reduce({[], 0}, fn character, {buffer, num_empty} ->
        case character do
          @round ->
            {[character | buffer], num_empty}

          @cube ->
            {[character | List.duplicate(@empty, num_empty) ++ buffer], 0}

          @empty ->
            {buffer, num_empty + 1}
        end
      end)

    (List.duplicate(@empty, num_empty) ++ buffer)
    |> Enum.reverse()
  end

  defp transpose(lines) do
    lines
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  defp score(lines) do
    num_lines = Enum.count(lines)

    {0, score} =
      Enum.reduce(lines, {num_lines, 0}, fn line, {line_index, acc} ->
        num_rounded =
          line
          |> Enum.filter(fn character -> character == @round end)
          |> Enum.count()

        {line_index - 1, acc + line_index * num_rounded}
      end)

    score
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
