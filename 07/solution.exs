defmodule Solution do
  @cards ~W(A K Q J T 9 8 7 6 5 4 3 2)
  @card_scores @cards |> Enum.reverse() |> Enum.with_index() |> Enum.into(%{})

  def part1 do
    rounds = input()
    {hands, _bids} = Enum.unzip(rounds)
    hand_ranks = rank_hands(hands)

    rounds
    |> winnings(hand_ranks)
    |> Enum.sum()
  end

  def part2 do
    input()
    nil
  end

  defp input do
    File.read!("07/input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [hand, bid] -> {hand, String.to_integer(bid)} end)
  end

  defp rank_hands(hands) do
    hands
    |> Enum.sort_by(&score_hand/1, :asc)
    |> Enum.with_index(1)
    |> Enum.into(%{})
  end

  defp score_hand(hand) do
    # A hand's score is the combination of its type and of its consituent cards.
    card_scores = hand_to_card_scores(hand)
    type_score = card_scores_to_type_score(card_scores)
    List.to_tuple([type_score | card_scores])
  end

  defp hand_to_card_scores(hand) do
    hand
    |> String.graphemes()
    |> Enum.map(fn card -> @card_scores[card] end)
  end

  defp card_scores_to_type_score(card_scores) do
    freqs = Enum.frequencies(card_scores) |> Map.values() |> Enum.sort()

    case freqs do
      # Five of a kind.
      [5] -> 6
      # Four of a kind.
      [1, 4] -> 5
      # Full house.
      [2, 3] -> 4
      # Three of a kind.
      [1, 1, 3] -> 3
      # Two pairs.
      [1, 2, 2] -> 2
      # One pair.
      [1, 1, 1, 2] -> 1
      # High card.
      [1, 1, 1, 1, 1] -> 0
    end
  end

  defp winnings(rounds, hand_ranks) do
    Enum.map(rounds, fn {hand, bid} ->
      bid * hand_ranks[hand]
    end)
  end
end

part1 = Solution.part1()
IO.puts("Part 1: #{inspect(part1)}")

part2 = Solution.part2()
IO.puts("Part 2: #{part2}")
