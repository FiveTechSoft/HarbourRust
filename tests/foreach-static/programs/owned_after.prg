function Work()
local a := {1,2,3}, x, sum := 0
for each x in a
sum := sum + x
next
local s := Upper("first")
for each x in a
sum := sum + x
next
local b := {"owned", "array"}
for each x in a
sum := sum + x
next
local t := Upper("last")
local decoded := hb_jsonDecode('["child",[1,2,3,4,5]]')
? sum, s, b[2], t
? hb_jsonEncode(decoded)
return nil

function Main()
Work()
? "cleanup complete"
return nil
