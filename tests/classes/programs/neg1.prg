CREATE CLASS A
   DATA x INIT 1
   METHOD M()
ENDCLASS
METHOD M() CLASS A
return Self
procedure main()
   local a := A():New2()
return
