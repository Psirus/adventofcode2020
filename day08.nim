import streams, strutils

type
  Instruction = object
    operation: string
    argument: int
    wasRun: bool

proc readCode(filename: string): seq[Instruction] =
  var line = ""
  var file = newFileStream(filename, fmRead)
  if not isNil(file):
    while file.readLine(line):
      let s = line.split(" ")
      let (op, arg) = (s[0], s[1])
      result.add(Instruction(operation: op, argument: arg.parseInt, wasRun: false))
    file.close()

var code = readCode("input/day08")

proc execCode(code: var seq[Instruction]): (int, bool) =
  var acc = 0
  var next_line = 0
  while true:
    var current_line = next_line
    var instr = code[current_line]
    if instr.wasRun:
      return (acc, false)
    
    if instr.operation == "acc":
      next_line = current_line + 1
      acc += instr.argument
    elif instr.operation == "jmp":
      next_line = current_line + instr.argument
    else:
      next_line = current_line + 1
    instr.wasRun = true
    code[current_line] = instr
    if next_line == code.len:
      return (acc, true)

var newCode: seq[Instruction]
deepcopy(newCode, code)
var (acc, success) = execCode(newCode)
echo acc

for k in 0..<code.len:
  if code[k].operation in ["nop", "jmp"]:
    deepcopy(newCode, code)
    if newCode[k].operation == "nop":
      newCode[k].operation = "jmp"
      (acc, success) = execCode(newCode)
      if success:
        break
    if newCode[k].operation == "jmp":
      newCode[k].operation = "nop"
      (acc, success) = execCode(newCode)
      if success:
        break

echo acc
