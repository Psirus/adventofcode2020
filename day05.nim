import strutils, streams, sequtils

var seats = "input/day05".open.readAll.splitLines
seats.delete(seats.len-1)

proc getSeat(seat_specifier: string): int =
  assert seat_specifier.len == 10
  let (row_spec, col_spec) = (seat_specifier[0..6], seat_specifier[7..^1])
  let row_bin = row_spec.replace('F', '0').replace('B', '1')
  let col_bin = col_spec.replace('L', '0').replace('R', '1')
  let row = fromBin[int](row_bin)
  let col = fromBin[int](col_bin)
  result = 8*row + col

let seat_ids = seats.map(getSeat)
let highest = max(seat_ids)
let lowest = min(seat_ids)
echo highest

for i in lowest..highest:
  if i notin seat_ids:
    echo i
