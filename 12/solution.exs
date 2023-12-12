defmodule Solution do
  @operational "."
  @damaged "#"
  @unknown "?"

  def part1 do
    input()
    |> Enum.map(fn {springs, damages} ->
      disputed_chunks = springs |> String.split(@operational) |> Enum.filter(&Kernel.!=(&1, ""))
      {disputed_chunks, damages}
    end)
    |> Enum.map(&compute_permutations/1)
    |> Enum.map(&Enum.count/1)
    |> Enum.sum()
  end

  def part2 do
    input()
    nil
  end

  defp input do
    File.read!("12/input.txt")
    # File.read!("12/example.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      [springs, damages] = String.split(line)
      damages = damages |> String.split(",") |> Enum.map(&String.to_integer/1)
      {springs, damages}
    end)
  end

  # No more chunks left and no more damaged springs to place; we're done.
  defp compute_permutations({[], []}), do: []

  # We have chunks left and no damaged springs left to account for.
  # That's OK if none of the remaining chunks already contain a damaged spring.
  # Otherwise, we have placed damaged springs too early.
  defp compute_permutations({disputed_chunks, []}) do
    disputed_chunks
    |> Enum.map(fn chunk ->
      chunk
      |> String.graphemes()
      |> Enum.all?(&Kernel.==(&1, @unknown))
    end)
    |> Enum.all?()
    |> if(do: [[]], else: [])
  end

  # We have damaged springs to place but have no chunks left to place them in.
  defp compute_permutations({[], _damages}), do: []

  defp compute_permutations({disputed_chunks, damages}) do
    [chunk | rest_chunks] = disputed_chunks
    [num_damaged | rest_damages] = damages

    # If the current chunk is all unknowns, we might not have to place a
    # damaged spring here. Otherwise, we must place the damaged spring sequence
    # superimposed on at least one of the existing damaged springs.
    with_skipped_chunk =
      chunk
      |> String.graphemes()
      |> Enum.all?(&Kernel.==(&1, @unknown))
      |> if(do: compute_permutations({rest_chunks, damages}), else: [])

    # This computation tries to use the current chunk, regardless of its contents.
    with_used_chunk =
      chunk
      |> chunk_damage_permutations(num_damaged)
      |> case do
        nil ->
          []

        :error ->
          []

        perms ->
          Enum.flat_map(perms, fn {prefix, remaining} ->
            compute_permutations({[remaining | rest_chunks], rest_damages})
            |> Enum.map(fn pperm ->
              [prefix | pperm]
            end)
          end)
      end

    with_skipped_chunk ++ with_used_chunk
  end

  defp chunk_damage_permutations(chunk, num_damaged) do
    chunk_length = String.length(chunk)

    if chunk_length < num_damaged do
      nil
    else
      for offset <- 0..(chunk_length - num_damaged) do
        {start, rest} = String.split_at(chunk, offset)
        {_to_replace, rest} = String.split_at(rest, num_damaged)
        {next, rest} = String.split_at(rest, 1)
        # Inserting damaged springs here will result in a contiguous length
        # greater than the damage number.
        if String.contains?(start, @damaged) or String.ends_with?(start, @damaged) or
             next == @damaged do
          nil
        else
          {start <> String.duplicate(@damaged, num_damaged) <> next, rest}
        end
      end
      |> Enum.filter(fn perm -> not is_nil(perm) end)
    end
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
