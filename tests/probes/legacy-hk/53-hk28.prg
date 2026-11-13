function main()
local e := {}
local eh := {=>}
local a := {5, 6, 7}
local x
for each x in e
    ? "never"
next
? "after empty"
for each x in eh
    ? "neverh"
next
? "after empty hash"
for each x in a
    if x = 6
        exit
    endif
    ? x
next
? "after exit"
? x
return nil
