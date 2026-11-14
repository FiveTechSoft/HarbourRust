CREATE CLASS A
   DATA x INIT 1
ENDCLASS
procedure main()
   local a := A()
   local b := a
   if a == b
      ? "same"
   endif
   if a != b
      ? "diff"
   endif
return
