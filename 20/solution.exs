defmodule Solution do
  def part1 do
    modules =
      input()
      |> parse()

    state = %{modules: modules, num_high: 0, num_low: 0, pulses: []}

    for _index <- 1..1000, reduce: state do
      state -> push_button(state)
    end
    |> compute_score()
  end

  def part2 do
    input()
    nil
  end

  defp input do
    File.read!("20/input.txt")
    |> String.trim()
    |> String.split("\n")
  end

  defp parse(lines) do
    lines
    |> Enum.map(&parse_line/1)
    |> Map.new()
    |> initialise_conjunctions()
  end

  defp parse_line(line) do
    [module, outputs] = String.split(line, " -> ")
    {name, type, state} = parse_module(module)
    {name, {type, parse_outputs(outputs), state}}
  end

  defp parse_module("broadcaster" = name), do: {name, :broadcaster, nil}
  defp parse_module(<<"%", name::bitstring>>), do: {name, :flipflop, :off}
  defp parse_module(<<"&", name::bitstring>>), do: {name, :conjunction, %{}}

  defp parse_outputs(outputs) do
    String.split(outputs, ", ")
  end

  defp initialise_conjunctions(modules) do
    # Map modules to their inputs.
    inputs = modules |> Map.keys() |> Enum.map(fn name -> {name, []} end) |> Map.new()

    inputs =
      for {name, {_type, outputs, _state}} <- modules, output <- outputs, reduce: inputs do
        acc -> Map.put(acc, output, [name | acc[output]])
      end

    # Update the state of all conjunction modules to include the initial state
    # of their inputs.
    conjunctions =
      modules
      |> Enum.filter(fn {_, {type, _, _}} ->
        type == :conjunction
      end)
      |> Enum.map(fn {name, {type, outputs, _state} = module} ->
        state = inputs[name] |> Enum.map(fn input -> {input, :low} end) |> Map.new()
        {name, {type, outputs, state}}
      end)
      |> Map.new()

    Map.merge(modules, conjunctions)
  end

  defp push_button(%{pulses: []} = state) do
    state = %{state | pulses: [{"button", "broadcaster", :low}]}
    tick(state)
  end

  defp tick(%{pulses: []} = state), do: state

  defp tick(%{pulses: [{src, dest, height} | pulses]} = state) do
    # The updated module and any pulses it sends, ordered oldest to newest.
    {state, pulses} =
      case process_pulse(state, {src, dest, height}) do
        {:ok, {module, module_pulses}} ->
          state = put_in(state, [:modules, dest], module)
          pulses = pulses ++ module_pulses
          {state, pulses}

        {:error, :dest_not_found} ->
          {state, pulses}
      end

    state
    |> record_pulse(height)
    |> Map.put(:pulses, pulses)
    |> tick()
  end

  defp record_pulse(state, :low) do
    %{state | num_low: state.num_low + 1}
  end

  defp record_pulse(state, :high) do
    %{state | num_high: state.num_high + 1}
  end

  defp process_pulse(state, {src, dest, height}) do
    if Map.has_key?(state.modules, dest) do
      {module_state, pulses} = process_pulse(state, src, state.modules[dest], height)
      pulses = Enum.map(pulses, fn {to, height} -> {dest, to, height} end)
      {:ok, {module_state, pulses}}
    else
      {:error, :dest_not_found}
    end
  end

  # A flip-flop does nothing on receiving a high pulse.
  defp process_pulse(state, _src, {:flipflop, _outputs, _module_state} = module, :high),
    do: {module, []}

  # An off flip-flop turns on and sends a high pulse on receiving a low pulse.
  defp process_pulse(state, _src, {:flipflop, outputs, :off}, :low) do
    pulses = for dest <- outputs, do: {dest, :high}
    {{:flipflop, outputs, :on}, pulses}
  end

  # An on flip-flop turns on and sends a high pulse on receiving a low pulse.
  defp process_pulse(state, _src, {:flipflop, outputs, :on}, :low) do
    pulses = for dest <- outputs, do: {dest, :low}
    {{:flipflop, outputs, :off}, pulses}
  end

  # A broadcaster forwards the pulse to all outputs.
  defp process_pulse(state, _src, {:broadcaster, outputs, nil} = module, height) do
    pulses = for dest <- outputs, do: {dest, height}
    {module, pulses}
  end

  # A conjunction sends a pulse according to the most recently received pulses from all of
  # its inputs, including this current pulse. If all inputs are high, it sends a low pulse,
  # otherwise a high pulse.
  defp process_pulse(state, src, {:conjunction, outputs, module_state}, height) do
    module_state = %{module_state | src => height}
    all_high? = module_state |> Map.values() |> Enum.all?(fn h -> h == :high end)
    send_height = if all_high?, do: :low, else: :high
    pulses = for dest <- outputs, do: {dest, send_height}
    {{:conjunction, outputs, module_state}, pulses}
  end

  defp compute_score(%{num_high: num_high, num_low: num_low}) do
    num_high * num_low
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
