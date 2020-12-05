import streams, sequtils, math, sugar

proc readForest(filename: string): seq[string] =
  var line = ""
  var file = newFileStream(filename, fmRead)
  if not isNil(file):
    while file.readLine(line):
      result.add(line)
    file.close()

let forest = readForest("input/day03")

proc getCollisions(forest: seq[string], stride: (int, int)): int =
  let patternLen = len(forest[0])
  var j = 0
  for i in countup(0, len(forest)-1, stride[1]):
    let row = forest[i]
    if row[j mod patternLen] == '#':
      result += 1
    j += stride[0]

echo getCollisions(forest, (3, 1))

let slopes = [(1, 1), (3, 1), (5, 1), (7, 1), (1, 2)]
echo prod(slopes.map(slope => forest.getCollisions(slope)))
