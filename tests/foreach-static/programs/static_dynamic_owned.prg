function Work()
local a := {1,2}, strings := {"one","two"}, x, s
local sum := 0
for each x in a
local first := Upper("first")
sum := sum + x
? first, x
next
local between := Upper("between")
? between
for each s in strings
local during := Upper("during")
? during, s
next
local after := Upper("after")
? sum, after
return nil

function Main()
Work()
? "done"
return nil
