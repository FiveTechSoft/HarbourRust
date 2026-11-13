// Dyn string through a parameter: cloned at the call boundary (the callee
// owns and frees its copy); the callee's reassignment never touches the
// caller. NIL comparison keeps the param Dyn (probe family n1).
function f( v )
   if v = NIL
      ? "is-nil"
   endif
   ? v
   ? valtype( v )
   v := "callee"
   ? v
   return

function main()
   local x
   x := "caller"
   f( x )
   ? x
   f( NIL )
   x := NIL
   ? hb_memcheck()
   return
