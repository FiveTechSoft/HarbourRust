// Reassignment inside a loop frees each old payload; a loop-local Dyn
// re-declared each iteration frees its previous value before re-init.
// The final hb_memcheck reads 1: y still owns its last clone AT PRINT
// TIME (the epilogue frees it after); the process-exit balance is clean.
function main()
   local x
   x := "init"
   for i := 1 to 3
      x := "iter"
      local y := x
      ? y
   next
   ? x
   x := NIL
   ? hb_memcheck()
   return
