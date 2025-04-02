package task_22

// https://leetcode.com/problems/validate-binary-search-tree/submissions/1594450875

class TreeNode(var value: Int, var left: TreeNode = null, var right: TreeNode = null)

object Solution {
  def isValidBST(root: TreeNode): Boolean = {
    def validate(n: TreeNode, low: Option[Long], high: Option[Long]): Boolean = n match {
      case null => true
      case n =>
        val v = n.value
        low.forall(v > _) && high.forall(v < _) &&
        validate(n.left, low, Some(v)) &&
        validate(n.right, Some(v), high)
    }
    validate(root, None, None)
  }
}
