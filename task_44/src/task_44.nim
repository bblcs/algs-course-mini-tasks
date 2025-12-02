type
  StackNode[T] = ref object
    val: T
    next: StackNode[T]

  Stack*[T] = object
    head: StackNode[T]
    len*: int

  PersistentQueue*[T] = object
    L, Lp, R, Rp, S: Stack[T]
    recopy: bool
    toCopy: int
    copied: bool

func isEmpty*[T](s: Stack[T]): bool =
  s.len == 0

func push*[T](s: Stack[T], val: T): Stack[T] =
  result.head = StackNode[T](val: val, next: s.head)
  result.len = s.len + 1

func peek*[T](s: Stack[T]): T =
  if s.head == nil:
    raise newException(IndexDefect, "stack empty")
  result = s.head.val

func pop*[T](s: Stack[T]): (Stack[T], T) =
  if s.head == nil:
    raise newException(IndexDefect, "stack empty")
  result = (Stack[T](head: s.head.next, len: s.len - 1), s.head.val)

func checkNormal[T](q: PersistentQueue[T]): PersistentQueue[T]
func checkRecopy[T](q: PersistentQueue[T]): PersistentQueue[T]

func additionalOperations[T](q: PersistentQueue[T]): PersistentQueue[T] =
  var
    toDo = 3
    Rn = q.R
    Sn = q.S
    Ln = q.L
    Lp = q.Lp
    Rp = q.Rp
    curCopied = q.copied
    curCopy = q.toCopy

  while not curCopied and toDo > 0 and Rn.len > 0:
    let (newRn, x) = Rn.pop()
    Rn = newRn
    Sn = Sn.push(x)
    toDo -= 1

  while toDo > 0 and Ln.len > 0:
    curCopied = true
    let (newLn, x) = Ln.pop()
    Ln = newLn
    Rn = Rn.push(x)
    toDo -= 1

  while toDo > 0 and Sn.len > 0:
    let (newSn, x) = Sn.pop()
    Sn = newSn
    if curCopy > 0:
      Rn = Rn.push(x)
      curCopy -= 1
    toDo -= 1

  if Sn.len == 0:
    return PersistentQueue[T](
      L: Lp,
      Lp: Stack[T](),
      R: Rn,
      Rp: Rp,
      S: Sn,
      recopy: false,
      toCopy: curCopy,
      copied: curCopied,
    )
  else:
    return PersistentQueue[T](
      L: Ln,
      Lp: Lp,
      R: Rn,
      Rp: Rp,
      S: Sn,
      recopy: true,
      toCopy: curCopy,
      copied: curCopied,
    )

func checkNormal[T](q: PersistentQueue[T]): PersistentQueue[T] =
  additionalOperations(q)

func checkRecopy[T](q: PersistentQueue[T]): PersistentQueue[T] =
  if q.L.len > q.R.len:
    var startRecopyQ = PersistentQueue[T](
      L: q.L,
      Lp: q.Lp,
      R: q.R,
      Rp: q.R,
      S: q.S,
      recopy: true,
      toCopy: q.R.len,
      copied: false,
    )
    return checkNormal(startRecopyQ)
  else:
    return PersistentQueue[T](
      L: q.L,
      Lp: q.Lp,
      R: q.R,
      Rp: q.R,
      S: q.S,
      recopy: false,
      toCopy: q.toCopy,
      copied: q.copied,
    )

func initPersistentQueue*[T](): PersistentQueue[T] =
  result = PersistentQueue[T]()

func isEmpty*[T](q: PersistentQueue[T]): bool =
  return not q.recopy and q.R.len == 0

func push*[T](q: PersistentQueue[T], val: T): PersistentQueue[T] =
  if not q.recopy:
    let newL = q.L.push(val)
    let nextQ = PersistentQueue[T](
      L: newL,
      Lp: q.Lp,
      R: q.R,
      Rp: q.Rp,
      S: q.S,
      recopy: q.recopy,
      toCopy: q.toCopy,
      copied: q.copied,
    )
    return checkRecopy(nextQ)
  else:
    let newLp = q.Lp.push(val)
    let nextQ = PersistentQueue[T](
      L: q.L,
      Lp: newLp,
      R: q.R,
      Rp: q.Rp,
      S: q.S,
      recopy: q.recopy,
      toCopy: q.toCopy,
      copied: q.copied,
    )
    return checkNormal(nextQ)

func pop*[T](q: PersistentQueue[T]): (PersistentQueue[T], T) =
  if q.isEmpty():
    raise newException(IndexDefect, "queue empty")

  if not q.recopy:
    let (newR, val) = q.R.pop()
    let nextQ = PersistentQueue[T](
      L: q.L,
      Lp: q.Lp,
      R: newR,
      Rp: q.Rp,
      S: q.S,
      recopy: q.recopy,
      toCopy: q.toCopy,
      copied: q.copied,
    )
    return (checkRecopy(nextQ), val)
  else:
    let (newRp, val) = q.Rp.pop()
    var curCopy = q.toCopy
    var nextR = q.R

    if q.toCopy > 0:
      curCopy -= 1
    else:
      let (poppedR, _) = nextR.pop()
      nextR = poppedR

    let nextQ = PersistentQueue[T](
      L: q.L,
      Lp: q.Lp,
      R: nextR,
      Rp: newRp,
      S: q.S,
      recopy: q.recopy,
      toCopy: curCopy,
      copied: q.copied,
    )
    return (checkNormal(nextQ), val)

func peek*[T](q: PersistentQueue[T]): T =
  if q.isEmpty():
    raise newException(IndexDefect, "queue empty")

  if not q.recopy:
    return q.R.peek()
  else:
    return q.Rp.peek()
