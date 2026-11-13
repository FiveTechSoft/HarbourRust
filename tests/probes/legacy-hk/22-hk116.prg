function main()
    local b := {1, 2}
    local a := {{9}, {8}}
    a[1] := b
    ? a[1][2]
    b[2] := 77
    ? a[1][2]
    ? b[2]
return nil
