defmodule Solution do
  @numeric_characters MapSet.new(~w"0 1 2 3 4 5 6 7 8 9")
  @non_symbol_characters MapSet.union(@numeric_characters, MapSet.new(~w"."))

  def part1 do
    # Build a map of coordinate to value.
    {{n_rows, n_cols}, grid} =
      input()
      |> create_grid()

    # Build a mask of coordinates which are adjacent to symbols.
    mask =
      create_mask(grid)

    # Extract part numbers as all numbers which have at least one digit
    # overlapping with the mask.
    part_numbers = extract_part_numbers(grid, {n_rows, n_cols}, mask)

    Enum.sum(part_numbers)
  end

  def part2 do
    input()
    nil
  end

  defp input do
    File.read!("03/input.txt")
    |> String.trim()
    |> String.split("\n")
  end

  defp create_grid(lines) do
    grid =
      for {line, row} <- Enum.with_index(lines),
          {character, column} <- Enum.with_index(String.graphemes(line)),
          into: %{} do
        {{row, column}, character}
      end

    n_rows = Enum.count(lines)
    n_cols = String.length(Enum.at(lines, 0))

    {{n_rows, n_cols}, grid}
  end

  defp create_mask(grid) do
    mask = for {key, _value} <- grid, into: %{}, do: {key, false}

    Enum.reduce(grid, mask, fn {coord, character}, mask ->
      local_mask =
        if MapSet.member?(@non_symbol_characters, character) do
          %{}
        else
          create_adjacent_mask(coord)
        end

      Map.merge(mask, local_mask)
    end)
  end

  defp create_adjacent_mask({row, column}) do
    coords = [
      {row - 1, column - 1},
      {row - 1, column},
      {row - 1, column + 1},
      {row, column - 1},
      {row, column + 1},
      {row + 1, column - 1},
      {row + 1, column},
      {row + 1, column + 1}
    ]

    for coord <- coords, into: %{}, do: {coord, true}
  end

  defp extract_part_numbers(grid, {n_rows, n_cols}, mask) do
    Enum.flat_map(0..(n_rows - 1), fn row ->
      {nums, final, masked} =
        Enum.reduce(0..(n_cols - 1), {[], 0, false}, fn col, {nums, current, masked} ->
          character = grid[{row, col}]

          nums =
            if not MapSet.member?(@numeric_characters, character) do
              if current > 0 and masked, do: [current | nums], else: nums
            else
              nums
            end

          {current, masked} =
            if MapSet.member?(@numeric_characters, character) do
              current = 10 * current + String.to_integer(character)
              masked = masked || mask[{row, col}]
              {current, masked}
            else
              {0, false}
            end

          {nums, current, masked}
        end)

      if final > 0 and masked do
        [final | nums]
      else
        nums
      end
    end)
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
