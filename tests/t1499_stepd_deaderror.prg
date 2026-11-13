// ains 1b step (c)-next: independent fixture, not Harbour source
// Verifier probe reversed_badowned: the DEAD owned arm would raise a
// type error (hb_ntos over a string cell); laziness must skip it in
// BOTH orientations.
procedure main()
? wrap()
? hb_memcheck()
return
function wrap()
local a := {1,"canary"}
show(a)
return 0
procedure show(s)
? iif(.T., s[2], hb_ntos(s[2]))
? iif(.F., hb_ntos(s[2]), s[2])
return
