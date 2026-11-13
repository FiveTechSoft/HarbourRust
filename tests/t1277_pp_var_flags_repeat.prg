#xcommand SHOW <!a!> [,<!b!>] [<tp:TYPE,AS> <t>] [<ini:INIT,ASSIGN> <v>] [<ex:EXPORTED,VISIBLE>] [<pr:PROTECTED>] [<hi:HIDDEN>] [<ro:READONLY,RO>] [<pe:PERSISTENT,PROPERTY>] [<sy:SYNC>] => ? <(a)> ; [? <(b)> ;] [? <(t)> ;] [? <v> ;] ? <.ex.> ; ? <.pr.> ; ? <.hi.> ; ? <.ro.> ; ? <.pe.> ; ? <.sy.>
procedure main()
local SYNC := 4
SHOW alpha EXPORTED VISIBLE EXPORTED
return
