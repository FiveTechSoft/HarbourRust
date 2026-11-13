function main()
local a := "the quick brown fox jumps over the lazy dogX"
local b := "the quick brown fox jumps over the lazy dogY"
local c := 0
for i := 1 to 3000000
  if a = b
    c := c + 1
  endif
  if a < b
    c := c + 2
  endif
  if a > b
    c := c + 3
  endif
  if a <> b
    c := c + 5
  endif
next
? c
return nil
