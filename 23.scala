package task_23

// https://leetcode.com/problems/balance-a-binary-search-tree/submissions/1594557395

import scala.collection.mutable.ListBuffer

class TreeNode(var value: Int, var left: TreeNode = null, var right: TreeNode = null)

object Solution {
  def balanceBST(root: TreeNode): TreeNode = {
    if root == null then { return null }

    val sorted: Vector[Int] = {
      val buf = ListBuffer[Int]()

      def inorder(n: TreeNode): Unit = if n != null then {
        inorder(n.left)
        buf += n.value
        inorder(n.right)
      }

      inorder(root)
      buf.toVector
    }

    def build(start: Int, fin: Int): TreeNode = {
      if start > fin then return null
      else
        val mid = start + (fin - start) / 2
        TreeNode(sorted(mid), build(start, mid - 1), build(mid + 1, fin))
    }

    build(0, sorted.length - 1)
  }
}
