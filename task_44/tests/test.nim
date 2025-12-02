# tests/test_queue.nim
import unittest
import ../src/task_44

suite "test":
  test "basic":
    let q0 = initPersistentQueue[int]()
    check q0.isEmpty() == true

    let q1 = q0.push(1)
    check q1.isEmpty() == false
    check q1.peek() == 1

    let q2 = q1.push(2)
    check q2.peek() == 1

    let (q3, val1) = q2.pop()
    check val1 == 1
    check q3.peek() == 2

    let (q4, val2) = q3.pop()
    check val2 == 2
    check q4.isEmpty() == true

  test "recopy":
    var q = initPersistentQueue[int]()

    q = q.push(1)
    q = q.push(2)
    q = q.push(3)

    var (qNext, val) = q.pop()
    check val == 1

    (qNext, val) = qNext.pop()
    check val == 2

    (qNext, val) = qNext.pop()
    check val == 3

    check qNext.isEmpty()

  test "big data":
    var q = initPersistentQueue[int]()
    let N = 1000

    for i in 0 ..< N:
      q = q.push(i)

    var qCheck = q
    for i in 0 ..< N:
      let (nextQ, val) = qCheck.pop()
      check val == i
      qCheck = nextQ

    check qCheck.isEmpty()

  test "interleaved operations":
    let q0 = initPersistentQueue[int]()
    let q1 = q0.push(1)
    let q2 = q1.push(2)

    let (qA, vA) = q2.pop()
    check vA == 1

    let qB = q2.push(3)
    let (qB1, vB1) = qB.pop()
    check vB1 == 1
    let (qB2, vB2) = qB1.pop()
    check vB2 == 2
    let (qB3, vB3) = qB2.pop()
    check vB3 == 3
