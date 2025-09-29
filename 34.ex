# https://leetcode.com/problems/unique-binary-search-trees/submissions/1786297904/

defmodule Solution do
  @spec num_trees(n :: integer) :: integer
  def num_trees(n) do
    Enum.reduce(1..n, [1], fn _, acc ->
      [Enum.zip_with(acc, Enum.reverse(acc), &(&1 * &2)) |> Enum.sum() | acc]
    end)
    |> List.first()
  end
end
