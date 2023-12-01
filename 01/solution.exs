defmodule Solution do
  @digit_words %{
    "one" => "1",
    "two" => "2",
    "three" => "3",
    "four" => "4",
    "five" => "5",
    "six" => "6",
    "seven" => "7",
    "eight" => "8",
    "nine" => "9"
  }
  @digits @digit_words |> Map.values() |> MapSet.new()

  def part1 do
    input()
    |> Enum.map(&extract_digits/1)
    |> Enum.map(&parse_digits/1)
    |> Enum.map(&combine_digits/1)
    |> Enum.sum()
  end

  def part2 do
    input()
    |> Enum.map(&extract_digits_and_words/1)
    |> Enum.map(&parse_digits/1)
    |> Enum.map(&combine_digits/1)
    |> Enum.sum()
  end

  defp input do
    File.read!("01/input.txt")
    |> String.trim()
    |> String.split("\n")
  end

  defp extract_digits(line) do
    line
    |> String.graphemes()
    |> Enum.filter(fn character -> MapSet.member?(@digits, character) end)
  end

  defp extract_digits_and_words(line) do
    matches =
      Enum.join(Enum.concat(Map.keys(@digit_words), Map.values(@digit_words)), "|")

    # Use a look-ahead assertion to find overlapping matches.
    # https://stackoverflow.com/a/11430936
    ~r/(?=(#{matches}))/
    |> Regex.scan(line)
    |> Enum.concat()
    |> Enum.filter(fn s -> s != "" end)
  end

  defp combine_digits(digits) do
    first = List.first(digits)
    last = List.last(digits)
    10 * first + last
  end

  defp parse_digits(digits) do
    Enum.map(digits, &parse_digit/1)
  end

  defp parse_digit(s) do
    digit = Map.get(@digit_words, s, s)
    {integer, _} = Integer.parse(digit)
    integer
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{part1}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
