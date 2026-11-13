#xcommand SHOW <!a!> [,<!b!>] [<tp:TYPE,AS> <!t!>] [<ini:INIT,ASSIGN> <v>] => ? <(a)> ; [? <(b)> ;] [? <(t)> ;] [? <v> ;]
procedure main()
local AS := 4
SHOW alpha INIT 1 + AS
return
