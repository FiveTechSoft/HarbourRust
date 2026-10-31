// ains 1b step (b): independent fixture, not Harbour source
procedure main()
local a := {{{1,2}}}
leftview(a)
? len(a)
return
procedure leftview(s)
local n
for n := 1 to len(s)
?? valtype(s[n])
if hb_isarray(s[n])
rightview(s[n])
endif
next
return
procedure rightview(t)
local n
for n := 1 to len(t)
?? valtype(t[n])
if hb_isarray(t[n])
leftview(t[n])
endif
next
return
