// t509: `==` between string-array cells compares CONTENT exactly
// (oracle hk133: .T./.F./.T. - equal content in distinct cells is
// .T., after an overwrite .F., same cell .T.). DArrS surface.
function main()
    local a := {}
    local b := {}
    AAdd(a, "hola")
    AAdd(b, "hola")
    if a[1] == b[1]
        ? 1
    else
        ? 0
    endif
    b[1] := "holaa"
    if a[1] == b[1]
        ? 0
    else
        ? 0
    endif
    if a[1] == a[1]
        ? 1
    else
        ? 0
    endif
return nil
