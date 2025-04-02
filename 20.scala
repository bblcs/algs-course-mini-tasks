package task_20

// https://leetcode.com/problems/serialize-and-deserialize-binary-tree/submissions/1594388343/

import scala.collection.mutable.Queue

class TreeNode(var value: Int, var left: TreeNode = null, var right: TreeNode = null)

class Codec {
  private val NULL_MARKER = "ඞ"
  private val DELIMETER   = " "

  def serialize(root: TreeNode): String = {
    def t(n: TreeNode): List[String] =
      if n == null then List(NULL_MARKER)
      else n.value.toString :: t(n.left) ::: t(n.right)
    t(root).mkString(DELIMETER)
  }

  def deserialize(data: String): TreeNode = {
    if data == null || data.isEmpty then { return null }
    val tokens = Queue.from(data.split(DELIMETER))

    def t(): TreeNode = {
      if tokens.isEmpty then { return null }
      val token = tokens.dequeue()
      if token == NULL_MARKER then return null
      else return TreeNode(token.toInt, t(), t())
    }

    t()
  }
}
