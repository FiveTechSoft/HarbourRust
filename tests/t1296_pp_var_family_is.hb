#xcommand SHOW <!a!> [,<!b!>] [<tp:TYPE,AS> <t>] [<ini:INIT,ASSIGN> <v>] [<ex:EXPORTED,VISIBLE>] => ? <(a)> ; [? <(b)> ;] [? <(t)> ;] [? <v> ;]
#xcommand SHOW <!a!> [AS <t>] IN <!sup!> => ? <(a)> ; ? <(sup)> ; [? <(t)> ;]
#xcommand SHOW <!a!> [AS <t>] IS <!other!> => ? <(a)> ; ? <(other)> ; [? <(t)> ;]
#xcommand SHOW <!a!> [AS <t>] IS <!other!> IN <!sup!> => ? <(a)> ; ? <(other)> ; ? <(sup)> ; [? <(t)> ;]
#xcommand SHOW <!a!> [AS <t>] IS <!other!> TO <!obj!> => ? <(a)> ; ? <(other)> ; ? <(obj)> ; [? <(t)> ;]
procedure main()
SHOW alpha IS beta
return
