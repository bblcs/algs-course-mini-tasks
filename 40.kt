// https://leetcode.com/problems/range-sum-query-mutable/submissions/1812442564/

class NumArray(nums: IntArray) {
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
        return getSum(root, left, right)
    }

    private fun getSum(node: Node?, l: Int, r: Int): Int {
        if (node == null) return 0

        if (l == node.lb && r == node.rb) {
            return node.sum
        }

        val m = (node.lb + node.rb).shr(1);
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
