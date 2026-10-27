function main()
local x := 0
local a := {1,2,3}
local i := 0
for each x in a
((x))
next
for i := 1 to 3
(IIF(.T., x++, ++x))
next
? x
return
