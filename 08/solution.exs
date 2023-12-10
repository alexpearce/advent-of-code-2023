defmodule Solution do
  def part1 do
    [instructions, _empty | node_edges] =
      input()

    nodes = parse_edges(node_edges)

    instructions
    |> String.graphemes()
    |> Stream.cycle()
    |> Enum.reduce_while({"AAA", 0}, fn instruction, {node, step} ->
      if node == "ZZZ" do
        {:halt, step}
      else
        {left, right} = nodes[node]
        choice = if instruction == "L", do: left, else: right
        {:cont, {choice, step + 1}}
      end
    end)
  end

  def part2 do
    input()
    nil
  end

  defp input do
    File.read!("08/input.txt")
    |> String.trim()
    |> String.split("\n")
  end

  defp parse_edges(node_edges) do
    node_edges
    |> Enum.map(&parse_node/1)
    |> Enum.into(%{})
  end

  def parse_node(line) do
    [_, node, left, right] = Regex.run(~r/([A-Z]+) = \(([A-Z]+), ([A-Z]+)\)/, line)
    {node, {left, right}}
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
