defmodule Solution do
  def part1 do
    {parts, workflows} = input()

    parts
    |> Enum.filter(&accept?(&1, workflows))
    |> Enum.map(&compute_score/1)
    |> Enum.sum()
  end

  def part2 do
    {_parts, workflows} = input()
    ranges = %{"x" => {1, 4000}, "m" => {1, 4000}, "a" => {1, 4000}, "s" => {1, 4000}}
    find_acceptance(ranges, workflows)
  end

  defp input do
    [workflows, [""], parts] =
      File.read!("19/input.txt")
      |> String.trim()
      |> String.split("\n")
      |> Enum.chunk_by(&(&1 == ""))

    {parse_parts(parts), parse_workflows(workflows)}
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

  defp find_acceptance(ranges, workflows) do
    start = workflows["in"]

    step_ranges(ranges, start, workflows)
  end

  defp step_ranges(ranges, [:accept | _steps], _workflows) do
    ranges
    |> Enum.map(fn {_key, {lo, hi}} -> 1 + hi - lo end)
    |> Enum.product()
  end

  defp step_ranges(_ranges, [:reject | _steps], _workflows),
    do: 0

  defp step_ranges(ranges, [{:goto, workflow} | _steps], workflows) do
    step_ranges(ranges, workflows[workflow], workflows)
  end

  defp step_ranges(ranges, [{:test, predicate, on_success} | steps], workflows) do
    {failure_ranges, success_ranges} = split_ranges(ranges, predicate)
    having_failed = step_ranges(failure_ranges, steps, workflows)
    having_succeeded = step_ranges(success_ranges, [on_success], workflows)
    having_failed + having_succeeded
  end

  defp split_ranges(ranges, predicate) do
    %{"var" => var} = predicate
    {failure_range, success_range} = split_range(ranges[var], predicate)
    {%{ranges | var => failure_range}, %{ranges | var => success_range}}
  end

  defp split_range({}, _predicate), do: {{}, {}}

  defp split_range(range, predicate) do
    {lo, hi} = range
    %{"op" => op, "val" => val} = predicate

    case op do
      :greater_than ->
        {
          create_range(lo, min(hi, val)),
          create_range(max(lo, val + 1), hi)
        }

      :less_than ->
        {
          create_range(max(lo, val), hi),
          create_range(lo, min(hi, val - 1))
        }
    end
  end

  defp create_range(lo, hi) when not lo < hi, do: {}
  defp create_range(lo, hi), do: {lo, hi}
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
