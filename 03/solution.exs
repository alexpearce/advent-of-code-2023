defmodule Solution do
  @numeric_characters MapSet.new(~w"0 1 2 3 4 5 6 7 8 9")
  @non_symbol_characters MapSet.union(@numeric_characters, MapSet.new(~w"."))
  @gear_character "*"

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
    {{n_rows, n_cols}, grid} =
      input()
      |> create_grid()

    # Build a map of coordinates to adjacent gears, if any.
    adjacent_gear_map = create_adjacent_gear_map(grid)

    # Extract all part numbers which have at least one digit adjacent to a gear,
    # and map each gear to those numbers.
    part_numbers_with_adjacent_gears =
      extract_gear_adjacent_part_numbers(grid, {n_rows, n_cols}, adjacent_gear_map)

    # Map gear coordinates to a list of all adjacent part numbers.
    gears_with_adjacent_numbers =
      group_part_numbers_by_adjacent_gears(part_numbers_with_adjacent_gears)

    # Multiply part numbers adjacent to the same gear.
    # Seems like the puzzle input guarantees at most two parts adjacent to one
    # gear.
    Enum.map(gears_with_adjacent_numbers, fn
      {_gear_coord, [part_a, part_b]} -> part_a * part_b
      {_gear_coord, _parts} -> 0
    end)
    |> Enum.sum()
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
          create_adjacent_mask(coord, true)
        end

      Map.merge(mask, local_mask)
    end)
  end

  defp create_adjacent_gear_map(grid) do
    mask = for {key, _value} <- grid, into: %{}, do: {key, nil}

    Enum.reduce(grid, mask, fn {coord, character}, mask ->
      local_mask =
        if character == @gear_character do
          create_adjacent_mask(coord, coord)
        else
          %{}
        end

      Map.merge(mask, local_mask)
    end)
  end

  defp create_adjacent_mask({row, column}, value) do
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

    for coord <- coords, into: %{}, do: {coord, value}
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
              masked = masked or mask[{row, col}]
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

  defp extract_gear_adjacent_part_numbers(grid, {n_rows, n_cols}, adjacent_gear_map) do
    Enum.flat_map(0..(n_rows - 1), fn row ->
      {nums, final, adjacent_gear} =
        Enum.reduce(0..(n_cols - 1), {[], 0, nil}, fn col, {nums, current, adjacent_gear} ->
          character = grid[{row, col}]

          nums =
            if not MapSet.member?(@numeric_characters, character) do
              if current > 0 and not is_nil(adjacent_gear),
                do: [{current, adjacent_gear} | nums],
                else: nums
            else
              nums
            end

          {current, adjacent_gear} =
            if MapSet.member?(@numeric_characters, character) do
              current = 10 * current + String.to_integer(character)
              adjacent_gear = adjacent_gear || adjacent_gear_map[{row, col}]
              {current, adjacent_gear}
            else
              {0, nil}
            end

          {nums, current, adjacent_gear}
        end)

      if final > 0 and not is_nil(adjacent_gear) do
        [{final, adjacent_gear} | nums]
      else
        nums
      end
    end)
  end

  defp group_part_numbers_by_adjacent_gears(part_numbers_with_adjacent_gears) do
    Enum.reduce(part_numbers_with_adjacent_gears, %{}, fn {part_number, gear_coord}, acc ->
      {_, acc} =
        Map.get_and_update(acc, gear_coord, fn
          nil -> {nil, [part_number]}
          parts -> {parts, [part_number | parts]}
        end)

      acc
    end)
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
