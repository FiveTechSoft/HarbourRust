// The true tag keeps i64::MIN an ordinary value (probe n2): it coexists
// with NIL in one dynamic array and round-trips through AAdd/read/print/
// compare. (The retired sentinel representation printed MIN as "NIL".)
function main()
local a := {}
local m := -9223372036854775807 - 1
AAdd(a, m)
AAdd(a, NIL)
? a[1]
? a[2]
? m
if m = -9223372036854775807 - 1
   ? "ok1"
else
   ? "BAD1"
endif
if a[1] = m
   ? "ok2"
else
   ? "BAD2"
endif
if a[2] = NIL
   ? "ok3"
else
   ? "BAD3"
endif
if a[1] = NIL
   ? "BAD4"
else
   ? "ok4"
endif
? m + 0
return nil
