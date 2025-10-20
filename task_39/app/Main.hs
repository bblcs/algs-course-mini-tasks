{-# LANGUAGE ImportQualifiedPost #-}

module Main where

import System.Random qualified as Random

data Treap a
  = Empty
  | Node
      { value :: a,
        priority :: Int,
        size :: Int,
        subTreeSum :: a,
        left :: Treap a,
        right :: Treap a
      }

sizeOf :: Treap a -> Int
sizeOf Empty = 0
sizeOf (Node {size = s}) = s

sumOf :: (Num a) => Treap a -> a
sumOf Empty = 0
sumOf (Node {subTreeSum = s}) = s

recalc :: (Num a) => Treap a -> Treap a
recalc Empty = Empty
recalc node@(Node {value = v, left = l, right = r}) =
  node
    { size = 1 + sizeOf l + sizeOf r,
      subTreeSum = v + sumOf l + sumOf r
    }

merge :: (Num a) => Treap a -> Treap a -> Treap a
merge Empty r = r
merge l Empty = l
merge l@(Node {priority = p1}) r@(Node {priority = p2})
  | p1 > p2 = recalc $ l {right = merge (right l) r}
  | otherwise = recalc $ r {left = merge l (left r)}

split :: (Num a) => Treap a -> Int -> (Treap a, Treap a)
split Empty _ = (Empty, Empty)
split node@(Node {left = l, right = r}) k =
  let leftSize = sizeOf l
   in if k <= leftSize
        then
          let (newLeft, newRight) = split l k
           in (newLeft, recalc $ node {left = newRight})
        else
          let (newLeft, newRight) = split r (k - leftSize - 1)
           in (recalc $ node {right = newLeft}, newRight)

fromList :: (Num a, Random.SplitGen g) => [a] -> g -> (Treap a, g)
fromList xs gen = foldl f (Empty, gen') (zip xs priorities)
  where
    (priorities, gen') = generatePriorities (length xs) gen
    f (tree, g) (val, prio) = (insertAtEnd tree val prio, g)

    generatePriorities n g =
      let (g1, g2) = Random.splitGen g
       in (take n $ Random.randoms g1, g2)

    insertAtEnd t val prio =
      let new = Node val prio 1 val Empty Empty
       in merge t new

rangeSum :: (Num a) => Treap a -> Int -> Int -> a
rangeSum tree from to
  | from > to = 0
  | otherwise =
      let (leftAndMiddle, _) = split tree (to + 1)
          (_, middle) = split leftAndMiddle from
       in sumOf middle

main :: IO ()
main = do
  let array = [123, 38, 23, 312, 33, 91, 32, 48, 17, 1] :: [Int]

  gen <- Random.getStdGen
  let (treap, _) = fromList array gen

  testSum "sum of [0..9]" treap array 0 9
  testSum "sum of [2..6]" treap array 2 6
  testSum "sum of [4..4]" treap array 4 4
  testSum "sum of [0..3]" treap array 0 3
  testSum "sum of [7..9]" treap array 7 9
  testSum "sum of [5..3]" treap array 5 3

testSum :: (Num a, Eq a, Show a) => String -> Treap a -> [a] -> Int -> Int -> IO ()
testSum name treap arr from to = do
  let treapRes = rangeSum treap from to
      expectedRes =
        if from > to
          then 0
          else sum . take (to - from + 1) . drop from $ arr
  let status = if treapRes == expectedRes then "OK" else "FAIL"
  putStrLn $ "[" ++ status ++ "] " ++ name
  putStrLn $ "  Expected: " ++ show expectedRes
  putStrLn $ "  Got:      " ++ show treapRes
