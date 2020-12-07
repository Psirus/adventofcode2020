import streams, strutils, sequtils

type Group = (string, int)

proc readForms(filename: string): seq[Group] =
  var group: Group
  var line = ""
  var file = newFileStream(filename, fmRead)
  if not isNil(file):
    while file.readLine(line):
      if line == "":
        result.add(group)
        group[0] = ""
        group[1] = 0
      else:
        group[0] &= line
        group[1] += 1
    result.add(group)
    file.close()

let forms = readForms("input/day06")
var sum = 0
for form in forms:
  sum += deduplicate(form[0]).len

echo sum

sum = 0
for form in forms:
  for x in 'a'..'z':
    if count(form[0], x) == form[1]:
      sum += 1

echo sum
