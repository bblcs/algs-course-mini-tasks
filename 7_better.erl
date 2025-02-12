-spec is_ideal_permutation(Nums :: [integer()]) -> boolean().
is_ideal_permutation(Nums) ->
  lists:all(fun({X,I}) -> abs(X-I) < 2 end, lists:zip(Nums, lists:seq(0,length(Nums)-1))).
