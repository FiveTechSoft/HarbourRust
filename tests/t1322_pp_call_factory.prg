PROCEDURE Main()
#xtranslate NAME(<x>([<args,...>])) => <x>
#xcommand DECLARE <!x!> => #xcommand SHOW <x> => QOut(7)
DECLARE NAME(New(1,2))
SHOW New
RETURN
