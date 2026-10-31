// borrow_match stale-moved fix: independent fixture, not Harbour source
// Same guardrail as t1476, mutation route (repro borrowidxmutate).
// Conservative named rejection; Harbour runs this rc 0 (registered
// divergence, t1465 family).
procedure main()
local a := {{1,2},{3,4}}
sink(a[take(a)])
return
function take(x)
x[1][1] := 99
return 1
procedure sink(s)
? Len(s)
return
