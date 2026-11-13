// a[i][j] on an array of arrays of arrays is iterable: the innermost
// child is BORROWED from the root owner; the root stays alive (hk60/hk61).
function main()
    local a := {{{1, 2}}, {{3, 4}}}
    local x := 0
    for each x in a[1][1]
        ? x
    next
    for each x in a[2][1]
        ? x
    next
    ? len(a)
    ? a[1][1][1]
return nil
