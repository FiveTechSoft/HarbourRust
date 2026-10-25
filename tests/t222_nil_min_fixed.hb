// Fixed-size arrays stay tagless [i64; N] (Rust model): i64::MIN stores
// and reads back exactly, no tag word involved. Contrast with dynamic
// arrays (tagged elements, t213).
function main()
local a := {0, 0}
local m := -9223372036854775807 - 1
a[1] := m
? a[1]
if a[1] = m
   ? "ok1"
else
   ? "BAD1"
endif
if a[1] = NIL
   ? "BAD2"
else
   ? "ok2"
endif
return nil
