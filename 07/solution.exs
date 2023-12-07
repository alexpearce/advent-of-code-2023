defmodule Solution do
  @cards ~W(A K Q J T 9 8 7 6 5 4 3 2)
  @card_scores @cards |> Enum.reverse() |> Enum.with_index(1) |> Enum.into(%{})
  @card_scores_with_joker_rule Map.put(@card_scores, "J", 0)

  def part1 do
    rounds = input()
    {hands, _bids} = Enum.unzip(rounds)
    hand_ranks = rank_hands(hands, @card_scores, false)

    rounds
    |> winnings(hand_ranks)
    |> Enum.sum()
  end

  def part2 do
    rounds = input()
    {hands, _bids} = Enum.unzip(rounds)
    hand_ranks = rank_hands(hands, @card_scores_with_joker_rule, true)

    rounds
    |> winnings(hand_ranks)
    |> Enum.sum()
  end

  defp input do
    File.read!("07/input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [hand, bid] -> {hand, String.to_integer(bid)} end)
  end

  defp rank_hands(hands, card_scores, joker_rule?) do
    hands
    |> Enum.sort_by(&score_hand(&1, card_scores, joker_rule?), :asc)
    |> Enum.with_index(1)
    |> Enum.into(%{})
  end

  defp score_hand(hand, card_scores, joker_rule?) do
    # A hand's score is the combination of its type and of its consituent cards.
    card_scores = hand_to_card_scores(hand, card_scores)
    type_score = card_scores_to_type_score(card_scores, joker_rule?)
    List.to_tuple([type_score | card_scores])
  end

  defp hand_to_card_scores(hand, card_scores) do
    hand
    |> String.graphemes()
    |> Enum.map(fn card -> card_scores[card] end)
  end

  defp card_scores_to_type_score(card_scores, joker_rule?) do
    freqs =
      Enum.frequencies(card_scores)
      |> find_best_hand(joker_rule?)
      |> Map.values()
      |> Enum.sort()

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

  defp find_best_hand(card_freqs, false = _joker_rule?), do: card_freqs

  defp find_best_hand(card_freqs, true = _joker_rule?) do
    case card_freqs[0] do
      nil ->
        # There are no jokers, so cannot do better.
        card_freqs

      5 ->
        # There are no non-jokers, so cannot do better.
        card_freqs

      joker_freq ->
        # Replace one joker with the most frequent non-joker card, then repeat.
        {most_frequent_card, freq} =
          card_freqs
          |> Map.drop([0])
          |> Enum.max_by(fn {_card, freq} -> freq end)

        card_freqs
        |> Map.put(0, joker_freq - 1)
        |> Map.reject(fn {_k, v} -> v == 0 end)
        |> Map.put(most_frequent_card, freq + 1)
        |> find_best_hand(true)
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
