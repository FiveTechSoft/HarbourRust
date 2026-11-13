// ains 1b step (c)-next: independent fixture, not Harbour source
// Two iif items per verb, across ??, qout and outstd (common path).
procedure main()
? wrap()
? hb_memcheck()
return
function wrap()
local a := {5,"five"}
show(a)
return 0
procedure show(s)
?? iif(hb_isnumeric(s[1]), hb_ntos(s[1]), s[1])
?? "|"
?? iif(hb_isnumeric(s[2]), hb_ntos(s[2]), s[2])
qout(iif(hb_isnumeric(s[1]), hb_ntos(s[1]), s[1]), iif(hb_isnumeric(s[2]), hb_ntos(s[2]), s[2]))
outstd("END:", iif(hb_isnumeric(s[2]), hb_ntos(s[2]), s[2]))
? ""
return
