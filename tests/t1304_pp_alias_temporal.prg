PROCEDURE Main()
#define ALIAS FIRST
#xcommand FIRST <x> => QOut(<x>)
#xcommand SECOND <x> => QOut(<x>)
ALIAS 7
#undef ALIAS
#define ALIAS SECOND
ALIAS 8
RETURN
