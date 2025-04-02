package task_21

// https://leetcode.com/problems/binary-tree-right-side-view/submissions/1594424304

import scala.collection.mutable.Queue
import scala.collection.mutable.ListBuffer

class TreeNode(var value: Int, var left: TreeNode = null, var right: TreeNode = null)

object Solution {
  def rightSideView(root: TreeNode): List[Int] = {
    val res = ListBuffer[Int]()

    def dfs(n: TreeNode, depth: Int): Unit = {
      if n == null then { return }
      if depth == res.size then res += n.value
      dfs(n.right, depth + 1)
      dfs(n.left, depth + 1)
    }

    dfs(root, 0)
    res.toList
  }
}
