function mk()
    local a := Array(2, 2, 2, 2)
    a[2, 1, 2, 1] := 9
return a
function main()
    local b := mk()
    ? len(b)
    ? len(b[2, 1, 2])
    ? b[2, 1, 2, 1]
    ? b[1, 1, 1, 1]
return nil
