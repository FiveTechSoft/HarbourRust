#xcommand SHOW <x> [AS <t>] [DECL] => ? <x>
#xcommand SHOW <x> INLINE <*body*> => ? <body>
#xcommand SHOW <x> CLASS <!cls!> => ? <x> + 2
PROCEDURE Main()
SHOW 7 INLINE 8
SHOW 7 CLASS Test
SHOW 7 DECL
RETURN
