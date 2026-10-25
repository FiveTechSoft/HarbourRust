// HB-EXACT (probe m7): nested write evaluates value, outer index, inner index; AAdd/ASize on a[i] evaluate the target index before the value
function side(x)
  ? x + 0
  return x
function main()
local a := {{1, 2}, {3, 4}}
a[side(1)][side(2)] := side(9)
AAdd(a[side(2)], side(7))
? a[1][2]
? a[2][3]
return nil
