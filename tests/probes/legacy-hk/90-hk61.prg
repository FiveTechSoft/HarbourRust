// root survives depth-3 loops
function main()
    local a := {{{1, 2}}, {{3, 4}}}
    local x := 0
    for each x in a[1][1]
        ? x
    next
    ? len(a)
    ? a[1][1][1]
return nil
