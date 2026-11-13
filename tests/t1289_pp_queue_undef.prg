#define X 1
#xcommand BOTH => ? X ; #undef X ; ? value
procedure main()
local value := 9
BOTH
return
