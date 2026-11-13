function work()
    local b := {1, 2}
    local a := {{9}, {8}}
    a[1] := b
    ? a[1][2]
    ? b[2]
    a[1][2] := 99
    ? b[2]
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
