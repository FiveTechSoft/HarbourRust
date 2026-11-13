// ains 1b step (c)-next: independent fixture, not Harbour source
// Canary: raw-cell printing must NEVER free the borrowed cell. DArrDyn
// string cells are tag 4 owned BY THE ARRAY; DArrS cells are tag 2.
// After printing, the arrays must be fully intact; memcheck runs after
// wrap() returns so its locals are already dead.
procedure main()
? wrap()
? hb_memcheck()
return
function wrap()
local a := {"aa","bb",7}
local b := {"cc","dd"}
show(a)
show(b)
? a[1]
? a[2]
? b[1]
? b[2]
return 0
procedure show(s)
local n
for n := 1 to len(s)
?? iif(hb_isnumeric(s[n]), hb_ntos(s[n]), s[n])
?? ","
next
return
