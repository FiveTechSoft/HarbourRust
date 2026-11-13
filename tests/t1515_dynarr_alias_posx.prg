// ains P2 stage 1 REGISTERED FAILURE MODE (documented differential, NOT
// Harbour compatibility): Harbour SHARES the array on `b := a`; stage 1
// has no shared ownership, so a statically-indeterminable Dyn-to-Dyn
// array copy is stopped by a runtime guard - rc 1, both slots keep their
// values. Static rejection applies where the owner tag is known.
procedure main()
local a, b
a := { 1, 2 }
b := a
? b[1]
return
