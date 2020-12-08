import os, strutils, streams, sequtils

proc createScript(files: seq[string], newFile: string) =
  var fileStream = newFileStream(newFile, fmWrite)
  filestream.writeLine("#!/bin/bash")
  for file in files:
    var executable = file
    executable.removeSuffix(".nim")
    fileStream.writeLine("./" & executable)
  filestream.close()

  discard execShellCmd("chmod +x " & newFile)


proc createOneExecutable(files: seq[string], newFile: string) =
  let combinedExe = newFileStream(newFile, fmWrite)
  for file in files:
    let fileStream = newFileStream(file, fmRead)
    combinedExe.write(filestream.readAll)
    fileStream.close()
  combinedExe.close()


proc collectImports(files: seq[string]): seq[string] =
  result = @[]
  var line = ""
  for file in files:
    let file = newFileStream(file, fmRead)
    if not isNil(file):
      while file.readLine(line):
        if line.startsWith("import"):
          line.removePrefix("import ")
          result.add(line.split(", "))
  result = result.deduplicate()
          

proc createBenchmark(files: seq[string], newFile: string) =
  let benchmarkFile = newFileStream(newFile, fmWrite)
  benchmarkFile.writeLine("import nimbench")
  let imports = collectImports(files)
  benchmarkFile.writeLine("import " & imports.join(", "))
  benchmarkFile.writeLine("")

  var line = ""
  for file in files:
    var name = file
    name.removeSuffix(".nim")
    benchmarkFile.writeLine("bench(" & name & ", m):")
    let fileStream = newFileStream(file, fmRead)
    if not isNil(filestream):
      while filestream.readLine(line):
        if line.startsWith("import"):
          continue
        else:
          benchmarkFile.writeLine(line.indent(2))
    fileStream.close()
    benchmarkFile.writeLine("")

  benchmarkFile.writeLine("runBenchmarks()")
  benchmarkFile.close()

var filenames: seq[string]
for file in walkFiles("day*.nim"):
  filenames.add(file)

let usage = "Use --script myscript.sh to create a Bash script.\nUse --merge allDays.nim to create a single nim file.\nUse --benchmark run_benchmark.nim to create a file for benchmarking using nimbench."
if paramCount() < 2:
  echo "Too few parameters.\n", usage
  quit(1)

let param1 = paramStr(1)
let param2 = paramStr(2)

if param1 == "--merge":
  createOneExecutable(filenames, param2)
elif param1 == "--script":
  createScript(filenames, param2)
elif param1 == "--benchmark":
  createBenchmark(filenames, param2)
else:
  echo "Unknown command.\n", usage
