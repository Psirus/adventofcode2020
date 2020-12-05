import streams, strutils

proc readReport(filename: string): seq[int] =
  var line = ""
  var file = newFileStream(filename, fmRead)
  if not isNil(file):
    while file.readLine(line):
      result.add(parseInt(line))
    file.close()

let expenseReport = readReport("input/day01")

block partOne:
  for entry in expenseReport:
    for entry2 in expenseReport:
      if entry + entry2 == 2020:
        echo entry*entry2
        break partOne

block partTwo:
  for entry in expenseReport:
    for entry2 in expenseReport:
      for entry3 in expenseReport:
        if entry + entry2 + entry3 == 2020:
          echo entry*entry2*entry3
          break partTwo
