procedure Main()
   local m := hb_mutexCreate()
   ? "eval-ret", hb_mutexEval(m, {|| 42 })
return
