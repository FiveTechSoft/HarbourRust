// ains 1b step (c)-next: independent fixture, not Harbour source
// Verifier finding on c6b10774: a REVERSED iif (raw cell as the true
// arm) printed the wrong side. Both orientations x both condition
// values: canary / 1 / 1 / canary.
procedure main()
? wrap()
? hb_memcheck()
return
function wrap()
local a := {1,"canary"}
show(a)
return 0
procedure show(s)
? iif(.T., s[2], hb_ntos(s[1]))
? iif(.F., s[2], hb_ntos(s[1]))
? iif(.T., hb_ntos(s[1]), s[2])
? iif(.F., hb_ntos(s[1]), s[2])
return
