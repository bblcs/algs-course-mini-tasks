# https://leetcode.com/problems/dungeon-game/submissions/1786327755/

defmodule Solution do
  @spec calculate_minimum_hp(dungeon :: [[integer]]) :: integer
  def calculate_minimum_hp(dungeon) do
    m = length(dungeon)
    n = length(Enum.at(dungeon, 0))

    map =
      Enum.reduce(m - 1..0//-1, %{{m, n - 1} => 1, {m - 1, n} => 1}, fn i, acc ->
        Enum.reduce(n - 1..0//-1, acc, fn j, inner_acc ->
          right_cost = Map.get(inner_acc, {i, j + 1}, :infinity)
          down_cost = Map.get(inner_acc, {i + 1, j}, :infinity)
          min_cost_after =
            cond do
              right_cost == :infinity -> down_cost
              down_cost == :infinity -> right_cost
              true -> min(right_cost, down_cost)
            end

          room_value = get_in(dungeon, [Access.at(i), Access.at(j)])
          needed_at_entry = max(1, min_cost_after - room_value)

          Map.put(inner_acc, {i, j}, needed_at_entry)
        end)
      end)

    Map.get(map, {0, 0})
  end
end
