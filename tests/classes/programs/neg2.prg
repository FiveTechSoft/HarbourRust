CREATE CLASS A
   DATA x INIT 1
   METHOD M()
ENDCLASS
METHOD M() CLASS A
return Self
procedure main()
   local a := A():M()
   a:M := 5
return
