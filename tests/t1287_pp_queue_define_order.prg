#define X 1
#xcommand PROBE <x> => ? <x>
#xcommand BOTH => PROBE X ; #undef X ; #define X 2 ; PROBE X
procedure main()
BOTH
? X
return
