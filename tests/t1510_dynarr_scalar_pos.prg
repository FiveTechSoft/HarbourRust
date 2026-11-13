// ains P2 stage 1: a bare LOCAL holds a scalar-cell array as a Dyn value
// (tag 8): literal assign, cell reads, reassign over the old value
// (string -> array -> array), Len/ValType/HB_ISARRAY, whole-var print
// (Harbour prints an empty line for a whole array - oracle-pinned).
procedure main()
local x
x := { 1, "ab", .t., NIL }
? x[1], x[2], x[3], x[4]
? len(x)
? valtype(x), hb_isarray(x)
? x
x := { 7, 8 }
? x[1] + x[2], len(x)
x := "back to string"
? x
x := { "only" }
? x[1], len(x)
return
