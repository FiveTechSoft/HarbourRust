PROCEDURE Main()
#define MODE 7
#xtranslate NAME(<x>) => <x>
#xcommand SHOW <x> => QOut(<x>)
#xcommand BOTH => SHOW NAME(MODE);#define MODE 8;SHOW NAME(MODE)
BOTH
RETURN
