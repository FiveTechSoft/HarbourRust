// Str() of a Dyn value in a threaded program. Integer and float Dyn
// values render; a string raises BASE/1099 (Harbour's terminal text):
// in a worker only that worker ends (its join yields NIL), on the main
// thread the process exits 1.
procedure Main()
   local t := {}, i, r
   for i := 1 to 3
      AAdd(t, hb_threadStart(@Work(), i))
      hb_threadJoin(t[i], @r)
      ? "thread", i, r
   next
   ? "main", Work(1)
   ? Work(3)
   ? "not reached"
return

function Work(n)
   local x
   x := n
   if n == 2
      x := n / 4
   endif
   if n == 3
      x := "txt"
   endif
return "[" + Str(x) + "]"
