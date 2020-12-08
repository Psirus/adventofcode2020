from macros import error
from os import `/`, splitFile

let
  pcreVersion = getEnv("PCREVER", "8.42")
  pcreSourceDir = "pcre-" & pcreVersion
  pcreArchiveFile = pcreSourceDir & ".tar.bz2"
  pcreDownloadLink = "https://downloads.sourceforge.net/pcre/" & pcreArchiveFile
  pcreInstallDir = (thisDir() / "pcre/") & pcreVersion
  # http://www.linuxfromscratch.org/blfs/view/8.1/general/pcre.html
  pcreConfigureCmd = ["./configure", "--prefix=" & pcreInstallDir, "--enable-pcre16", "--enable-pcre32", "--disable-shared"]
  pcreIncludeDir = pcreInstallDir / "include"
  pcreLibDir = pcreInstallDir / "lib"
  pcreLibFile = pcreLibDir / "libpcre.a"

proc dollar[T](s: T): string =
  result = $s

proc mapconcat[T](s: openArray[T]; sep = " "; op: proc(x: T): string = dollar): string =
  ## Concatenate elements of ``s`` after applying ``op`` to each element.
  ## Separate each element using ``sep``.
  for i, x in s:
    result.add(op(x))
    if i < s.len-1:
      result.add(sep)

task installPcre, "Installs PCRE using musl-gcc":
  if not fileExists(pcreLibFile):
    if not dirExists(pcreSourceDir):
      if not fileExists(pcreArchiveFile):
        exec("curl -LO " & pcreDownloadLink)
      exec("tar xf " & pcreArchiveFile)
    else:
      echo "PCRE lib source dir " & pcreSourceDir & " already exists"
    withDir pcreSourceDir:
      putEnv("CC", "musl-gcc -static")
      exec(pcreConfigureCmd.mapconcat())
      exec("make -j8")
      exec("make install")
  else:
    echo pcreLibFile & " already exists"
  setCommand("nop")

# -d:musl
when defined(musl):
  var
    muslGccPath: string
  echo "  [-d:musl] Building a static binary using musl .."
  muslGccPath = findExe("musl-gcc")
  if muslGccPath == "":
    error("'musl-gcc' binary was not found in PATH.")
  switch("passL", "-static")
  switch("gcc.exe", muslGccPath)
  switch("gcc.linkerexe", muslGccPath)
  # -d:pcre
  when defined(pcre):
    if not fileExists(pcreLibFile):
      selfExec "installPcre"    # Install PCRE in current dir if pcreLibFile is not found
    switch("passC", "-I" & pcreIncludeDir) # So that pcre.h is found when running the musl task
    switch("define", "usePcreHeader")
    switch("passL", pcreLibFile)

# nim musl foo.nim
task musl, "Builds an optimized static binary using musl":
  ## Usage: nim musl <FILE1> <FILE2> ..
  var
    switches: seq[string]
    nimFiles: seq[string]
  let
    numParams = paramCount()

  # param 0 will always be "nim"
  # param 1 will always be "musl"
  for i in 2 .. numParams:
    if paramStr(i)[0] == '-':    # -d:foo or --define:foo
      switches.add(paramStr(i))
    else:
      # Non-switch parameters are assumed to be Nim file names.
      nimFiles.add(paramStr(i))

  if nimFiles.len == 0:
    error(["The 'musl' sub-command accepts at least one Nim file name",
           "  Examples: nim musl FILE.nim",
           "            nim musl FILE1.nim FILE2.nim"].mapconcat("\n"))
  # optimization
  switches.add(@["-d:danger", "-d:pcre"])

  for f in nimFiles:
    let
      extraSwitches = switches.mapconcat()
      (dirName, baseName, _) = splitFile(f)
      binFile = dirName / baseName  # Save the binary in the same dir as the nim file
      nimArgsArray = ["c", "-d:musl", extraSwitches, f]
      nimArgs = nimArgsArray.mapconcat()

    # Build binary
    echo "\nRunning 'nim " & nimArgs & "' .."
    selfExec nimArgs

    echo "\nCreated binary: " & binFile
