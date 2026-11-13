// borrow_match stale-moved fix: independent fixture, not Harbour source
// The index of a borrowed element may not mention the owner array: an
// indirect call there could consume it before the borrow (repro
// borrowidxmove2). Conservative named rejection; Harbour runs this rc 0
// (registered divergence, t1465 family).
procedure main()
local a := {{1,2},{3,4}}
sink(a[take(a)])
return
function take(x)
? Len(x[1])
return 1
procedure sink(s)
? Len(s)
return
