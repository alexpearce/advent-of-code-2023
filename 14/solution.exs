defmodule Solution do
  @round "O"
  @cube "#"
  @empty "."

  def part1 do
    input()
    |> transpose()
    |> Enum.map(&shift_rocks/1)
    |> transpose()
    |> score()
  end

  def part2 do
    input()
    nil
  end

  defp input do
    File.read!("14/input.txt")
    # File.read!("14/example.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
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
