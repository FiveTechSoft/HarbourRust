function main()
    local a := Array(2)
    local b := Array(2)
    a[1] := "hola"
    b[1] := "hola"
    ? a[1] == b[1]
    b[1] := "holaa"
    ? a[1] == b[1]
    ? a[1] == a[1]
return nil
