// ains 1b step (b) fix: independent fixture, not Harbour source
// The index of a view argument may not mention the viewed array: an
// indirect call there could consume the owner before the sub-view exists
// (independent-review repro index_consume_only). Conservative named
// rejection; Harbour runs this rc 0 (registered divergence, t1465 family).
procedure main()
local a := {{1,2},{3,4}}
show(a[take(a)])
return
function take(x)
? Len(x[1])
return 1
procedure show(s)
? ValType(s[1])
return
