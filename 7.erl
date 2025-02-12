-spec is_ideal_permutation(Nums :: [integer()]) -> boolean().
is_ideal_permutation(Nums) ->
  {_, GlobalInversions} = merge_sort_and_count(Nums),
  LocalInversions = count_local_inversions(Nums),
  GlobalInversions == LocalInversions.

merge_sort_and_count([]) -> {[], 0};
merge_sort_and_count([H]) -> {[H], 0};
merge_sort_and_count(Nums) ->
  {Left, Right} = lists:split(length(Nums) div 2, Nums),
  {SortedLeft, LeftInversions} = merge_sort_and_count(Left),
  {SortedRight, RightInversions} = merge_sort_and_count(Right),
  {Merged, MergeInversions} = merge(SortedLeft, SortedRight, 0),
  {Merged, LeftInversions + RightInversions + MergeInversions}.

merge([], [], Inversions) -> {[], Inversions};
merge([], Right, Inversions) -> {Right, Inversions};
merge(Left, [], Inversions) -> {Left, Inversions};
merge([LeftHead | LeftTail], [RightHead | RightTail], Inversions) ->
  case LeftHead =< RightHead of
    true ->
      {NewList, NewInversions} = merge(LeftTail, [RightHead | RightTail], Inversions),
      {[LeftHead | NewList], NewInversions};
    false ->
      {NewList, NewInversions} = merge([LeftHead | LeftTail], RightTail, Inversions + length([LeftHead | LeftTail])),
      {[RightHead | NewList], NewInversions}
  end.

count_local_inversions([]) -> 0;
count_local_inversions([_]) -> 0;
count_local_inversions([H1, H2 | T]) ->
  (case H1 > H2 of
     true -> 1;
     false -> 0
   end) + count_local_inversions([H2 | T]).
