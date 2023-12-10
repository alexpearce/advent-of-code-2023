# https://programming-idioms.org/idiom/75/compute-lcm/983/elixir
defmodule Math do
  def gcd(a, 0), do: a
  def gcd(0, b), do: b
  def gcd(a, b), do: gcd(b, rem(a, b))

  def lcm(0, 0), do: 0
  def lcm(a, b), do: Integer.floor_div(a * b, gcd(a, b))
end

defmodule Solution do
  def part1 do
    {instructions, nodes} = input()

    instructions
    |> Stream.cycle()
    |> Enum.reduce_while({"AAA", 0}, fn instruction, {current_node, step} ->
      if current_node == "ZZZ" do
        {:halt, step}
      else
        next_node = choose_node(nodes, current_node, instruction)
        {:cont, {next_node, step + 1}}
      end
    end)
  end

  def part2 do
    {instructions, nodes} = input()

    starting_nodes =
      nodes
      |> Map.keys()
      |> Enum.filter(&String.ends_with?(&1, "A"))

    steps_to_nearest_z =
      Enum.map(starting_nodes, fn starting_node ->
        instructions
        |> Stream.cycle()
        |> Enum.reduce_while({starting_node, 0}, fn instruction, {current_node, step} ->
          if String.ends_with?(current_node, "Z") do
            {:halt, step}
          else
            next_node = choose_node(nodes, current_node, instruction)
            {:cont, {next_node, step + 1}}
          end
        end)
      end)

    Enum.reduce(steps_to_nearest_z, 1, &Math.lcm(&1, &2))
  end

  defp input do
    [instructions, _empty | node_edges] =
      File.read!("08/input.txt")
      |> String.trim()
      |> String.split("\n")

    nodes = parse_edges(node_edges)

    instructions = instructions |> String.graphemes()

    {instructions, nodes}
  end

  defp parse_edges(node_edges) do
    node_edges
    |> Enum.map(&parse_node/1)
    |> Enum.into(%{})
  end

  defp parse_node(line) do
    [_, node, left, right] = Regex.run(~r/([A-Z]+) = \(([A-Z]+), ([A-Z]+)\)/, line)
    {node, {left, right}}
  end

  defp choose_node(nodes, node, direction) do
    {left, right} = nodes[node]
    if direction == "L", do: left, else: right
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
