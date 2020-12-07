import streams, strutils, re, sequtils

proc readPassports(filename: string): seq[string] =
  var passport = ""
  var line = ""
  var file = newFileStream(filename, fmRead)
  if not isNil(file):
    while file.readLine(line):
      if line == "":
        result.add(passport)
        passport = ""
      elif passport == "":
        passport &= line
      else:
        passport &= " " & line
    result.add(passport)
    file.close()

let passports = readPassports("input/day04")


proc isValid(passport: string): bool =
  result = true
  for field in ["byr:", "iyr:", "eyr:", "hgt:", "hcl:", "ecl:", "pid:"]:
    result = result and passport.contains(field)

let fewer_passports = passports.filter(isValid)

echo fewer_passports.len

proc isValid2(passport: string): bool =
  result = true
  let fields = passport.split(" ")
  for field in fields:
    let parts = field.split(":")
    var (key, value) = (parts[0], parts[1])
    case key:
    of "byr":
      let year = value.parseInt
      if year < 1920 or year > 2002: return false
    of "iyr":
      let year = value.parseInt
      if year < 2010 or year > 2020: return false
    of "eyr":
      let year = value.parseInt
      if year < 2020 or year > 2030: return false
    of "hgt":
      if value.endsWith("in"):
        value.removeSuffix("in")
        let height = value.parseInt
        if height < 59 or height > 76: return false
      elif value.endsWith("cm"):
        value.removeSuffix("cm")
        let height = value.parseInt
        if height < 150 or height > 193: return false
      else:
        return false
    of "hcl":
      let regex = re"^#[0-9a-f]{6}$"
      if not match(value, regex): return false
    of "ecl":
      if value notin @["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]:
        return false
    of "pid":
      let regex = re"^\d{9}$"
      if not match(value, regex): return false

echo fewer_passports.filter(isValid2).len
