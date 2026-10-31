// ains P2 stage 1 closure (independent-review blocker on 6896c79f): a
// Dyn-held ARRAY may not cross a normal parameter boundary - the callee
// owns and frees its parameters (SIGSEGV before this closure).
// Registered runtime failure: rc 1, the caller keeps the value. The
// AView bridge is the only array crossing (guarded separately).
procedure main()
local x
x := { 1, "canary" }
f(x)
? x[2]
return
procedure f(t)
? t
return
