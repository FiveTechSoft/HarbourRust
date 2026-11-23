function Work()
local a := {1,2}, b := {10,20}, x, y
local total := 0
for each x in a
local outer := Upper("outer")
for each y in b
local inner := Upper("inner")
local parts := {"left","right"}
total := total + x + y
? outer, inner, parts[2], x, y
next
local afterInner := Upper("after inner")
? afterInner
next
local tail := Upper("tail")
? total, tail
return nil

function Main()
Work()
? "done"
return nil
