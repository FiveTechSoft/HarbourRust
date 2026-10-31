#xcommand SHOW <x> [AS <t>] [DECL] => ? <x> ; [? <(t)> ;]
PROCEDURE Main()
SHOW f(2,3)+1 DECL AS number
RETURN
FUNCTION f(a,b)
RETURN a+b
