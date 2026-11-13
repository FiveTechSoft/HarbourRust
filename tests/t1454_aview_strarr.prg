// ains 1b step (b): independent fixture, not Harbour source
procedure main()
run()
? hb_memcheck()
return
procedure run()
local h := {"x"=>1,"long"=>2}
local a := hb_hkeys(h)
show(a)
? a[1]
return
procedure show(s)
local n
for n := 1 to len(s)
?? valtype(s[n])
next
return
