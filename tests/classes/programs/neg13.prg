CREATE CLASS A
   DATA x INIT 1
ENDCLASS
procedure main()
   local a := A()
   if a == NIL
      ? "nil"
   endif
return
