defmodule Solution do
  def part1 do
    input()
    |> build_adjacency_list()
    # Found by visualising the graph with GraphViz.
    |> remove_edges([{"vmq", "cbl"}, {"klk", "xgz"}, {"bvz", "nvf"}])
    |> connected_components()

    nil
  end

  def part2 do
    input()
    nil
  end

  defp input do
    File.read!("25/input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    [node, neighbours] = String.split(line, ": ")
    neighbours = String.split(neighbours, " ")
    {node, neighbours}
  end

  defp build_adjacency_list(lines) do
    Enum.reduce(lines, %{}, fn {node, neighbours}, acc ->
      neighbours
      |> Enum.reduce(acc, fn neighbour, acc ->
        acc
        |> add_connection({node, neighbour})
        |> add_connection({neighbour, node})
      end)
    end)
  end

  defp add_connection(map, {src, dest}) do
    Map.update(map, src, MapSet.new([dest]), fn set ->
      MapSet.put(set, dest)
    end)
  end

  defp remove_edges(adj, edges) do
    Enum.reduce(edges, adj, fn {src, dest}, adj ->
      adj
      |> Map.put(src, MapSet.delete(adj[src], dest))
      |> Map.put(dest, MapSet.delete(adj[dest], src))
    end)
  end

  defp connected_components(adj) do
    Enum.reduce(adj, {%{}, []}, fn {node, _neighbours}, {visited, components} ->
      visited = visit([node], adj, visited)
      IO.inspect(Enum.count(visited))

      {visited, components}
    end)
  end

  defp visit([] = _frontier, _adj, visited), do: visited

  defp visit([node | frontier], adj, visited) do
    if Map.has_key?(visited, node) do
      visit(frontier, adj, visited)
    else
      frontier = MapSet.to_list(adj[node]) ++ frontier
      visited = Map.put(visited, node, true)
      visit(frontier, adj, visited)
    end
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
