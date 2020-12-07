import streams, strutils, re

type
  Policy = object
    lower, upper: int
    letter: char

let regex = re"(\d+)-(\d+) (\w): (\w+)"

proc parseLine(line: string): (Policy, string) =
  var matches: array[4, string]
  doAssert match(line, regex, matches)
  let (lower, upper) = (parseInt(matches[0]), parseInt(matches[1]))
  let policy = Policy(lower: lower, upper: upper, letter: matches[2][0])
  result = (policy, matches[3])

proc readPasswords(filename: string): seq[(Policy, string)] =
  var line = ""
  var file = newFileStream(filename, fmRead)
  if not isNil(file):
    while file.readLine(line):
      result.add(parseLine(line))
    file.close()

proc isValid(policy: Policy, password: string): bool =
  let numOccurences = count(password, policy.letter)
  return (numOccurences >= policy.lower) and (numOccurences <= policy.upper)

let passwordDb = readPasswords("input/day02")

var numValidPasswords = 0
for (policy, password) in passwordDb:
  if isValid(policy, password):
    numValidPasswords += 1

echo numValidPasswords

proc isValid2(policy: Policy, password: string): bool =
  let left = policy.letter == password[policy.lower - 1]
  let right = policy.letter == password[policy.upper - 1]
  result = left xor right

numValidPasswords = 0
for (policy, password) in passwordDb:
  if isValid2(policy, password):
    numValidPasswords += 1

echo numValidPasswords
