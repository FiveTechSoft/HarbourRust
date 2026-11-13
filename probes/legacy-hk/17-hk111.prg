function muta(a)
    a[1, 2, 1, 1] := 42
    ? a[1, 2, 1, 1]
return nil
function main()
    local a := Array(2, 2, 2, 2)
    muta(a)
    ? a[1, 2, 1, 1]
return nil
