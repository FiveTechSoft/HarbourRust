function main()
local i := 3
local a := {10,20,30,40,50}
? a[i--], i
? IIF(.F., ++i, --i), i
? .F. .AND. ++i > 0, i
? .T. .OR. --i > 0, i
return
