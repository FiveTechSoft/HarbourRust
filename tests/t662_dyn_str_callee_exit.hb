// memcheck AT FUNCTION EXIT, not only at process level: a callee that
// receives a Dyn string (cloned at the boundary) and one that builds and
// returns one both verify a zero live count INSIDE, before returning.
// The returned clone is accounted on the caller side (1 live until the
// caller NILs its slot).
function take( v )
   if v = NIL
      ? "is-nil"
   endif
   v := "swapped"
   ? hb_memcheck()
   return

function mk()
   local r
   r := "built"
   return r

function main()
   local x
   x := "owned"
   take( x )
   ? hb_memcheck()
   x := mk()
   ? hb_memcheck()
   x := NIL
   ? hb_memcheck()
   return
