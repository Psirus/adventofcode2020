import streams, strutils, re, sequtils

type
  Rule = object
    container: string
    contents: seq[(int, string)]

proc readRules(filename: string): seq[Rule] =
  var line = ""
  var matches: array[2, string]
  var file = newFileStream(filename, fmRead)
  if not isNil(file):
    while file.readLine(line):
      let s = line.split(" bags contain ")
      let (container_str, content_str) = (s[0], s[1])
      if content_str.startsWith("no"):
        result.add(Rule(container: container_str, contents: @[]))
        continue

      var content_list: seq[(int, string)]
      for content in content_str.split(", "):
        doAssert content.match(re"(\d) ([a-z ]*) bag", matches)
        content_list.add((matches[0].parseInt, matches[1]))
      result.add(Rule(container: container_str, contents: content_list))
    file.close()

let rules = readRules("input/day07")

proc num_containers(color_list: seq[string], new_colors: seq[string]): (seq[string], seq[string]) =
  if new_colors.len == 0:
    return (color_list, new_colors)

  result[0] = color_list
  result[1] = @[]
  for color in new_colors:
    for rule in rules:
      for subcontent in rule.contents:
        if subcontent[1] == color:
          result[1].add(rule.container)
  
  result[1] = result[1].deduplicate
  for color in result[1]:
    if color notin result[0]:
      result[0].add(color)
  return num_containers(result[0], result[1])

let (color_list, new_colors) = num_containers(@[], @["shiny gold"])
echo color_list.len

proc num_contents(color_list: seq[string]): int =
  if color_list.len == 0:
    return 0

  var num = 0
  var inside_colors: seq[string] = @[]
  for color in color_list:
    for rule in rules:
      if rule.container == color:
        for subcontent in rule.contents:
          num += subcontent[0] + subcontent[0] * num_contents(@[subcontent[1]])
  
  return num + num_contents(inside_colors)

let inside = num_contents(@["shiny gold"])
echo inside
