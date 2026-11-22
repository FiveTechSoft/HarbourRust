function Work()
local a := {1,2,3}, x
for each x in a
local s := Upper("exit")
? s, x
exit
next
local afterExit := Upper("after exit")
? afterExit
for each x in a
local t := Upper("loop")
if x < 3
loop
endif
? t, x
next
local afterLoop := Upper("after loop")
? afterLoop
return nil

function Main()
Work()
? "done"
return nil
