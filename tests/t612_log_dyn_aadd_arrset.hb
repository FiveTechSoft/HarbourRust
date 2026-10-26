// t612: AAdd grows a logical cell and ArrSet overwrites one (oracle hk208,
// first part)
function main()
    local a := {}
    aadd( a, 1 )
    aadd( a, .T. )
    a[1] := .F.
    ? a[2]
    ? valtype( a[2] )
    ? a[1]
return nil
