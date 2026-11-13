#xcommand PROBE <x> => ? <x>
#xcommand BOTH => PROBE 1 ; PROBE 2
#xcommand FOUR => BOTH ; BOTH
procedure main()
local X := 9
FOUR
return
