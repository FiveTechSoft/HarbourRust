// ains P2 stage 1: cell mutation on a Dyn-held array - scalar widening in
// place (int -> string -> logical -> NIL), owned-string cell replacement
// frees the old payload (memcheck = 0 after the loop).
procedure main()
local x, i
x := { 1, 2, 3 }
x[2] := "widened"
? x[1], x[2], x[3]
x[2] := .f.
? valtype(x[2]), x[2]
x[3] := NIL
? valtype(x[3])
x[1] := "alpha"
x[1] := "beta-gamma"
? x[1]
for i := 1 to 200
   x[1] := "omega"
next
? x[1]
return
