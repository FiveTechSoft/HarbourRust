procedure main()
   local b := {|| inspect()}
   Eval(b)
return
function inspect()
   local n
   for n := 0 to 6
      ? n, ProcName(n), ProcLine(n)
   next
return nil
