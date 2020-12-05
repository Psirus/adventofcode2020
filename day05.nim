import strutils, sequtils

var seats = "input/day05".open.readAll.splitLines
seats.delete(seats.len-1)

proc getSeat(seatSpecifier: string): int =
  assert seatSpecifier.len == 10
  let (rowSpec, colSpec) = (seatSpecifier[0..6], seatSpecifier[7..^1])
  let rowBin = rowSpec.replace('F', '0').replace('B', '1')
  let colBin = colSpec.replace('L', '0').replace('R', '1')
  let row = fromBin[int](rowBin)
  let col = fromBin[int](colBin)
  result = 8*row + col

let seatIds = seats.map(getSeat)
let highest = max(seatIds)
let lowest = min(seatIds)
echo highest

for i in lowest..highest:
  if i notin seatIds:
    echo i
