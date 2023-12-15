defmodule Solution do
  def part1 do
    input()
    |> Enum.map(&hash/1)
    |> Enum.sum()
  end

  def part2 do
    input()
    |> lens_initialisation(%{})
    |> Enum.into([])
    |> focusing_power()
  end

  defp input do
    File.read!("15/input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.join()
    |> String.split(",")
  end

  defp hash(s) do
    s
    |> String.to_charlist()
    |> Enum.reduce(0, fn codepoint, acc ->
      acc = acc + codepoint
      acc = 17 * acc
      rem(acc, 256)
    end)
  end

  defp lens_initialisation([], boxes), do: boxes

  defp lens_initialisation([step | steps], boxes) do
    step = decode_step(step)
    lens_initialisation(steps, apply_step(step, boxes))
  end

  defp decode_step(step) do
    if String.contains?(step, "=") do
      [label, focal_length] = String.split(step, "=")
      {:replace, {label, String.to_integer(focal_length)}}
    else
      [label, ""] = String.split(step, "-")
      {:remove, label}
    end
  end

  # It would be more efficient to perform remove/replace operations if each
  # box was a map whose keys were ordered by insertion time, e.g. a map
  # whose entries point to a node in a doubly linked list, or Python's dict
  # implementation. In lieu of a stdlib implementation we model each box as a
  # list of of `{key, value}` tuples.
  defp apply_step({:remove, key}, boxes), do: remove_lens(boxes, key)
  defp apply_step({:replace, {key, value}}, boxes), do: replace_lens(boxes, key, value)

  defp remove_lens(boxes, key) do
    box_index = hash(key)
    box = Map.get(boxes, box_index, [])
    Map.put(boxes, box_index, do_remove(box, key))
  end

  defp do_remove([], _key), do: []
  defp do_remove([{key, _value} | tail], key), do: tail
  defp do_remove([head | tail], key), do: [head | do_remove(tail, key)]

  defp replace_lens(boxes, key, focal_length) do
    box_index = hash(key)
    box = Map.get(boxes, box_index, [])

    box =
      case do_replace(box, key, focal_length) do
        {:error, :not_found} ->
          [{key, focal_length} | box]

        box ->
          box
      end

    Map.put(boxes, box_index, box)
  end

  defp do_replace([{key, _value} | tail], key, value), do: [{key, value} | tail]

  defp do_replace([head | tail], key, value) do
    case do_replace(tail, key, value) do
      {:error, :not_found} = error ->
        error

      tail ->
        [head | tail]
    end
  end

  defp do_replace([], _key, _value), do: {:error, :not_found}
  defp do_replace({:error, :not_found}, _key, _value), do: {:error, :not_found}

  defp focusing_power(boxes, acc \\ 0)

  defp focusing_power([], acc), do: acc

  defp focusing_power([{box_index, box} | boxes], acc) do
    focusing_power(boxes, acc + box_power(box, box_index))
  end

  defp box_power(box, box_index) do
    box
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(fn {{_label, focal_length}, lens_index} ->
      lens_power(box_index, lens_index, focal_length)
    end)
    |> Enum.sum()
  end

  defp lens_power(box_index, lens_index, focal_length) do
    (1 + box_index) * (1 + lens_index) * focal_length
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
