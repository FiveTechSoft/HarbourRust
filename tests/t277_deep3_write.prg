function main()
    local a := {{{1, 2}}, {{3}}}
    a[1][1][2] := 99
    ? a[1][1][2]
    ? a[1][1][1]
    ? len(a)
    ? len(a[1])
    ? len(a[1][1])
return
