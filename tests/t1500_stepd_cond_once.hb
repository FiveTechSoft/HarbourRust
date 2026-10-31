// ains 1b step (c)-next: independent fixture, not Harbour source
// Verifier probe cond_once: the condition evaluates EXACTLY ONCE
// (n ends at 1; a double evaluation would print 2).
procedure main()
? wrap()
? hb_memcheck()
return
function wrap()
local a := {1,"canary"}
local n := 0
? iif(++n = 1, hb_ntos(a[1]), a[2])
? n
return 0
