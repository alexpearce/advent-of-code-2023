defmodule Solution do
  def part1 do
    lines = input()

    {lines, seeds} = parse_seeds(lines)
    maps = parse_maps(lines)

    locations =
      find_locations(seeds, maps)

    Enum.min(locations)
  end

  defp find_locations(seeds, maps) do
    Enum.map(seeds, fn seed ->
      Enum.reduce(maps, seed, fn ranges, source ->
        fallback = {source..source, source..source}

        {%Range{first: src_start}, %Range{first: dest_start}} =
          Enum.find(ranges, fallback, fn {src_range, _dest_range} ->
            source in src_range
          end)

        src_offset = source - src_start

        dest_start + src_offset
      end)
    end)
  end

  def part2 do
    input()
    nil
  end

  defp input do
    File.read!("05/input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.filter(fn
      "" -> false
      _line -> true
    end)
  end

  defp parse_seeds([seeds_line | lines]) do
    [_ | seeds] = String.split(seeds_line)
    seeds = Enum.map(seeds, &String.to_integer/1)
    {lines, seeds}
  end

  defp parse_maps(lines) do
    lines
    |> Enum.reduce([], fn line, acc ->
      if Regex.match?(~r/^[0-9]/, line) do
        [curr_ranges | acc] = acc

        [dst_start, src_start, range_length] =
          line |> String.split() |> Enum.map(&String.to_integer/1)

        new_range =
          {Range.new(src_start, src_start + range_length - 1),
           Range.new(dst_start, dst_start + range_length - 1)}

        curr_ranges = [new_range | curr_ranges]

        [curr_ranges | acc]
      else
        [[] | acc]
      end
    end)
    |> Enum.reverse()
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
