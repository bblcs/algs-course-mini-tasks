package task_24

// https://leetcode.com/problems/maximum-frequency-stack/submissions/1594594029

import scala.collection.mutable.Map
import scala.collection.mutable.Stack

class FreqStack() {
  private type Frequency = Int
  private val freqMap  = Map.empty[Int, Frequency]
  private val stackMap = Map.empty[Frequency, Stack[Int]]

  private var maxFreq = 0

  def push(value: Int): Unit = {
    val curFreq = freqMap.getOrElse(value, 0)
    val newFreq = curFreq + 1
    freqMap(value) = newFreq

    if newFreq > maxFreq then { maxFreq = newFreq }

    val fittingStack = stackMap.getOrElseUpdate(newFreq, Stack.empty[Int])
    fittingStack.push(value)

  }

  def pop(): Int = {
    val topFreqStack = stackMap(maxFreq)
    val valueToPop   = topFreqStack.pop()
    freqMap(valueToPop) -= 1
    if topFreqStack.isEmpty then {
      maxFreq -= 1
    }
    valueToPop
  }
}
