PROCEDURE Main()
#define ALIAS END
#xcommand FIRST => #define ALIAS HOP ; ALIAS 7
#xcommand HOP <x> => QOut(<x>)
FIRST
RETURN
