procedure Main()
   local m := hb_mutexCreate()
   ? "type", ValType(m)
   ? "not-nil", m != NIL
return
