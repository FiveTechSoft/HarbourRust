// a[i] on an array of arrays is iterable: the subarray is BORROWED from
// the root owner for the loop; the root stays alive afterwards (hk53/hk54).
function main()
    local a := {{1, 2}, {3, 4}}
    local x := 0
    for each x in a[1]
        ? x
    next
    for each x in a[2]
        ? x
    next
    ? len(a)
    ? a[1][1]
return nil
