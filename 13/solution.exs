defmodule Solution do
  def part1 do
    input()
    |> Enum.chunk_by(fn line -> line == "" end)
    |> Enum.filter(fn chunk -> chunk != [""] end)
    |> Enum.map(&find_split/1)
    |> Enum.reduce(0, fn
      {:vertical, split}, acc -> acc + split
      {:horizontal, split}, acc -> acc + 100 * split
    end)
  end

  def part2 do
    input()
    nil
  end

  defp input do
    File.read!("13/input.txt")
    |> String.trim()
    |> String.split("\n")
  end

  defp find_split(lines) do
    case do_find_split(lines) do
      nil ->
        {:vertical, do_find_split(transpose(lines))}

      index ->
        {:horizontal, index}
    end
  end

  defp do_find_split([]), do: nil

  defp do_find_split(lines) do
    num_lines = Enum.count(lines)

    Enum.reduce_while(1..(num_lines - 1), nil, fn split, _result ->
      {left, right} = Enum.split(lines, split)

      left
      |> Enum.reverse()
      |> Enum.zip(right)
      |> Enum.map(fn {a, b} -> a == b end)
      |> Enum.all?()
      |> if do
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
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
