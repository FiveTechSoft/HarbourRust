function make()
    local a := Array(2, 3)
    a[1][1] := 7
return a[1][1]
function main()
    local v := make()
    ? v
    ? hb_memcheck()
return
