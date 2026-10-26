// Dyn-to-Dyn copy clones the payload (Harbour value semantics): y keeps
// its own "abc" after x changes; self-assignment is safe; Dyn-vs-Dyn
// string compare is by content (hk145 with owned tag-4 casillas).
function main()
   local x, y
   x := "abc"
   y := x
   x := "changed"
   ? y
   y := x
   x := y
   ? x
   x := "same"
   y := x
   ? x == y
   ? x = y
   x := NIL
   y := NIL
   ? hb_memcheck()
   return
