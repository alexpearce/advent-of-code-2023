defmodule Solution do
  def part1 do
    [workflows, [""], parts] =
      input()
      |> Enum.chunk_by(&(&1 == ""))

    workflows = parse_workflows(workflows)

    parts
    |> parse_parts()
    |> Enum.filter(&accept?(&1, workflows))
    |> Enum.map(&compute_score/1)
    |> Enum.sum()
  end

  def part2 do
    input()
    nil
  end

  defp input do
    File.read!("19/input.txt")
    |> String.trim()
    |> String.split("\n")
  end

  defp parse_workflows(workflows) do
    workflows
    |> Enum.map(&parse_workflow/1)
    |> Map.new()
  end

  defp parse_workflow(workflow) do
    %{"name" => name, "steps" => steps} =
      ~r/(?<name>[a-z]+)\{(?<steps>.*)\}/
      |> Regex.named_captures(workflow)

    {name, parse_steps(steps)}
  end

  defp parse_steps(steps) do
    steps
    |> String.split(",")
    |> Enum.map(&parse_step/1)
  end

  defp parse_step("A"), do: :accept
  defp parse_step("R"), do: :reject

  defp parse_step(step) do
    case String.split(step, ":") do
      [predicate, workflow] ->
        on_success =
          case workflow do
            "A" -> parse_step("A")
            "R" -> parse_step("R")
            workflow -> {:goto, workflow}
          end

        {:test, parse_predicate(predicate), on_success}

      [workflow] ->
        {:goto, workflow}
    end
  end

  defp parse_predicate(predicate) do
    %{"var" => var, "op" => op, "val" => val} =
      Regex.named_captures(~r/(?<var>[a-z]+)(?<op>[<>])(?<val>\d+)/, predicate)

    op =
      case op do
        ">" -> :greater_than
        "<" -> :less_than
      end

    val = String.to_integer(val)

    %{"var" => var, "op" => op, "val" => val}
  end

  defp parse_parts(parts) do
    Enum.map(parts, &parse_part/1)
  end

  defp parse_part(part) do
    ~r/\{x\=(?<x>\d+),m\=(?<m>\d+),a\=(?<a>\d+),s\=(?<s>\d+)\}/
    |> Regex.named_captures(part)
    |> Enum.map(fn {k, v} -> {k, String.to_integer(v)} end)
    |> Map.new()
  end

  defp accept?(part, workflows) do
    process(part, workflows) == :accept
  end

  defp process(part, workflows) do
    start = workflows["in"]
    process_workflow(part, start, workflows)
  end

  defp process_workflow(_part, [:accept | _steps], _workflows), do: :accept
  defp process_workflow(_part, [:reject | _steps], _workflows), do: :reject

  defp process_workflow(part, [{:goto, workflow} | _steps], workflows) do
    process_workflow(part, workflows[workflow], workflows)
  end

  defp process_workflow(part, [{:test, predicate, on_success} | steps], workflows) do
    steps = if predicate_passes?(part, predicate), do: [on_success], else: steps
    process_workflow(part, steps, workflows)
  end

  defp predicate_passes?(part, %{"op" => :greater_than} = predicate) do
    part[predicate["var"]] > predicate["val"]
  end

  defp predicate_passes?(part, %{"op" => :less_than} = predicate) do
    part[predicate["var"]] < predicate["val"]
  end

  defp compute_score(part) do
    part
    |> Map.values()
    |> Enum.sum()
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
