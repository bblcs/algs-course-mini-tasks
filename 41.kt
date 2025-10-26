// https://leetcode.com/problems/count-of-smaller-numbers-after-self/submissions/1812463729/

class Solution {
    private class NumArray(nums: IntArray) {
        private class Node(
            val lb: Int,
            val rb: Int,
            var sum: Int,
            var left: Node? = null,
            var right: Node? = null
        )

        private var root: Node? = null

        init {
            if (nums.isNotEmpty()) {
                root = buildTree(nums, 0, nums.size - 1)
            }
        }

        private fun buildTree(nums: IntArray, l: Int, r: Int): Node {
            if (l == r) {
                return Node(l, r, nums[l])
            }

            val m = l + (r - l).shr(1)
            val left = buildTree(nums, l, m)
            val right = buildTree(nums, m + 1, r)

            val node = Node(l, r, left.sum + right.sum)
            node.left = left
            node.right = right
            return node
        }

        fun update(index: Int, `val`: Int) {
            updateTree(root, index, `val`)
        }

        private fun updateTree(node: Node?, index: Int, value: Int) {
            if (node == null) return

            if (node.lb == node.rb) {
                node.sum = value
                return
            }

            val m = node.lb + (node.rb - node.lb).shr(1)

            if (index <= m) {
                updateTree(node.left, index, value)
            } else {
                updateTree(node.right, index, value)
            }

            node.sum = (node.left?.sum ?: 0) + (node.right?.sum ?: 0)
        }

        fun sumRange(left: Int, right: Int): Int {
            if (left > right) return 0
            return getSum(root, left, right)
        }



        private fun getSum(node: Node?, l: Int, r: Int): Int {
            if (node == null) return 0

            if (l == node.lb && r == node.rb) {
                return node.sum
            }

            val m = (node.rb + node.lb).shr(1);
            var res = 0

            if (l <= m) {
                res += getSum(node.left, l, min(r, m))
            }

            if (r >= m + 1) {
                res += getSum(node.right, max(l, m + 1), r)
            }

            return res
        }
    }


    fun countSmaller(nums: IntArray): List<Int> {
        if (nums.isEmpty()) {
            return emptyList()
        }

        val sorted = nums.toSet().sorted()
        val rankMap = sorted.withIndex().associate { it.value to it.index }

        val freqArr = IntArray(sorted.size) { 0 }
        val st = NumArray(freqArr)

        val counts = IntArray(nums.size)

        for (i in nums.indices.reversed()) {
            val num = nums[i]
            val rank = rankMap[num]!!

            val smallerCount = st.sumRange(0, rank - 1)
            counts[i] = smallerCount

            val currentfreq = st.sumRange(rank, rank)
            st.update(rank, currentfreq + 1)
        }

        return counts.toList()
    }
}
