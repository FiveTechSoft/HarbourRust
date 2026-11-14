CREATE CLASS A
   DATA x INIT 1
ENDCLASS
CREATE CLASS B
   DATA y INIT 2
ENDCLASS
procedure main()
   local a := A()
   local b := B()
   a:x := b
return
