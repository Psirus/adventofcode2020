import strutils, tables, sets, parseutils

proc parseLine(line: string): (string, seq[(int, string)]) =
    let s = line.split(" bags contain ")
    let (container_str, content_str) = (s[0], s[1])
    if content_str.startsWith("no"):
      return (container_str, @[])

    var content_list: seq[(int, string)]
    var color: string
    for content in content_str.split(", "):
      discard content[2..^1].parseUntil(color, " bag")
      let num = parseInt($(content[0]))
      content_list.add((num, color))
    result = (container_str, content_list)

let input = "input/day07".open.readAll.splitLines

var inverted_table = initTable[string, seq[string]]()
var rules_table = initTable[string, seq[(int, string)]]()

for line in input:
  if line.len == 0:
    continue
  let (container, contents) = parseLine(line)
  for content in contents:
    inverted_table.mgetOrPut(content[1], @[]).add(container)
  rules_table[container] = contents


proc num_containers(table: Table[string, seq[string]], color_list: var HashSet[string], color: string) =
  let container_colors = table.getOrDefault(color)
  for new_color in container_colors:
    color_list.incl(new_color)
    num_containers(table, color_list, new_color)

var color_set = initHashSet[string]()
num_containers(inverted_table, color_set, "shiny gold")
echo color_set.len

proc num_contents(color_list: seq[string]): int =
  if color_list.len == 0:
    return 0

  var num = 0
  var inside_colors: seq[string] = @[]
  for color in color_list:
    let rule = rules_table[color]
    for subcontent in rule:
      num += subcontent[0] + subcontent[0] * num_contents(@[subcontent[1]])
  
  return num + num_contents(inside_colors)

let inside = num_contents(@["shiny gold"])
echo inside
