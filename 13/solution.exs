defmodule Solution do
  def part1 do
    input()
    |> solve(0)
  end

  def part2 do
    input()
    |> solve(1)
  end

  defp input do
    File.read!("13/input.txt")
    |> String.trim()
    |> String.split("\n")
  end

  defp solve(lines, allowed_differences) do
    lines
    |> Enum.chunk_by(fn line -> line == "" end)
    |> Enum.filter(fn chunk -> chunk != [""] end)
    |> Enum.map(&find_split(&1, allowed_differences))
    |> Enum.reduce(0, fn
      {:vertical, split}, acc -> acc + split
      {:horizontal, split}, acc -> acc + 100 * split
    end)
  end

  defp find_split(lines, allowed_differences) do
    case do_find_split(lines, allowed_differences) do
      nil ->
        {:vertical, do_find_split(transpose(lines), allowed_differences)}

      index ->
        {:horizontal, index}
    end
  end

  defp do_find_split(lines, allowed_differences) do
    num_lines = Enum.count(lines)

    Enum.reduce_while(1..(num_lines - 1), nil, fn split, _result ->
      {left, right} = Enum.split(lines, split)

      num_differences =
        left
        |> Enum.reverse()
        |> Enum.zip(right)
        |> Enum.map(&differences/1)
        |> Enum.sum()

      if num_differences == allowed_differences do
        {:halt, split}
      else
        {:cont, nil}
      end
    end)
  end

  defp transpose(lines) do
    lines
    |> Enum.map(&String.graphemes/1)
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.join/1)
  end

  defp differences({a, b}) do
    Enum.zip(String.graphemes(a), String.graphemes(b))
    |> Enum.map(fn {i, j} ->
      if i != j, do: 1, else: 0
    end)
    |> Enum.sum()
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
