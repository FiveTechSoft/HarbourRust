function main()
    local a := Array(2)
    a[1] := "hola"
    ? a[1] == "hola"
    ? a[1] == "hola "
    ? a[1] == "hol"
    ? "hola" == a[1]
return nil
