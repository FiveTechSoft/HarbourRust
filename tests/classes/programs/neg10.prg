CREATE CLASS A
   DATA x INIT 1
ENDCLASS
CREATE CLASS B
ENDCLASS
procedure main()
   local b := B()
   local a := A()
   b := a
return
