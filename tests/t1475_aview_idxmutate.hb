// ains 1b step (b) fix: independent fixture, not Harbour source
// Same guardrail as t1474, mutation route: the index call mutates the
// owner (independent-review repro own_index_mutate). Conservative named
// rejection; Harbour runs this rc 0 (registered divergence, t1465 family).
procedure main()
local a := {{1,2},{3,4}}
show(a[take(a)])
return
function take(x)
x[1][1] := 99
return 1
procedure show(s)
? ValType(s[1])
return
