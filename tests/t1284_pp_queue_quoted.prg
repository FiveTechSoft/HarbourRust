#xcommand PROBE <x> => ? <x>
#xcommand BOTH => PROBE "a;b" ; PROBE "c;d"
procedure main()
local X := 9
BOTH
return
