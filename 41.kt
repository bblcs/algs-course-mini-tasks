// https://leetcode.com/problems/count-of-smaller-numbers-after-self/submissions/1887319300/

class Solution {
    private class MergeTree(val nums: IntArray) {
        class Node(
            val lb: Int,
            val rb: Int,
            val sortedData: IntArray,
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
                return Node(l, r, intArrayOf(nums[l]))
            }

            val m = l + (r - l) / 2
            val leftNode = buildTree(nums, l, m)
            val rightNode = buildTree(nums, m + 1, r)

            val merged = merge(leftNode.sortedData, rightNode.sortedData)

            val node = Node(l, r, merged)
            node.left = leftNode
            node.right = rightNode
            return node
        }

        private fun merge(arr1: IntArray, arr2: IntArray): IntArray {
            val res = IntArray(arr1.size + arr2.size)
            var i = 0
            var j = 0
            var k = 0
            while (i < arr1.size && j < arr2.size) {
                if (arr1[i] < arr2[j]) {
                    res[k++] = arr1[i++]
                } else {
                    res[k++] = arr2[j++]
                }
            }
            while (i < arr1.size) res[k++] = arr1[i++]
            while (j < arr2.size) res[k++] = arr2[j++]
            return res
        }

        fun querySmaller(queryL: Int, queryR: Int, value: Int): Int {
            if (queryL > queryR) return 0
            return query(root, queryL, queryR, value)
        }

        private fun query(node: Node?, l: Int, r: Int, value: Int): Int {
            if (node == null) return 0
            
            if (l > node.rb || r < node.lb) {
                return 0
            }
            if (l <= node.lb && r >= node.rb) {
                return countStrictlySmaller(node.sortedData, value)
            }

            return query(node.left, l, r, value) + query(node.right, l, r, value)
        }

        private fun countStrictlySmaller(arr: IntArray, target: Int): Int {
            var low = 0
            var high = arr.size
            while (low < high) {
                val mid = (low + high) ushr 1
                if (arr[mid] < target) {
                    low = mid + 1
                } else {
                    high = mid
                }
            }
            return low
        }
    }

    fun countSmaller(nums: IntArray): List<Int> {
        if (nums.isEmpty()) return emptyList()

        val mst = MergeTree(nums)
        val result = IntArray(nums.size)

        for (i in nums.indices) {
            val count = mst.querySmaller(i + 1, nums.size - 1, nums[i])
            result[i] = count
        }

        return result.toList()
    }
}
