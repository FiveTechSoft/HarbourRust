// t599: logical literals and dotted operators (oracle hk197)
function main()
    local a := .T.
    local b := .F.
    ? a
    ? b
    ? a .AND. b
    ? a .OR. b
    ? .NOT. a
    ? .T. .AND. .T.
    ? ValType(a)
return nil
