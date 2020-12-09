import streams, strutils, math

proc readNumbers(filename: string): seq[int] =
  var line = ""
  var file = newFileStream(filename, fmRead)
  if not isNil(file):
    while file.readLine(line):
      result.add(parseInt(line))
    file.close()

let numbers = readNumbers("input/day09")

proc isMadeUpOf(x: int, ys: seq[int]): bool =
  result = false
  for (i, y) in ys.pairs():
    if x - y in ys[i..^1]:
      return true

proc findError(list: seq[int], preamble_size: int): int =
  for i in preamble_size..<list.len:
    let x = list[i]
    if not x.isMadeUpOf(list[i - preamble_size..<i]):
      return x

let error = findError(numbers, 25)

proc findSum(list: seq[int], target: int): seq[int] =
  let targetIdx = list.find(target)
  let maxLen = int(target_idx/2)
  for sumlen in 2..maxLen:
    for k in 0..targetIdx:
      if sum(list[k..k+sumlen]) == target:
        return list[k..k+sumlen]

let terms = findSum(numbers, error)
echo max(terms) + min(terms)
