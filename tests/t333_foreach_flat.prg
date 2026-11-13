// for each over a flat numeric array: elements, count, array alive after (oracles hk17/hk26).
function main()
    local a := {}
    local x := 0
    AAdd(a, 5)
    AAdd(a, 6)
    for each x in a
        ? x
    next
    ? len(a)
    a[1] := 99
    ? a[1]
    ? a[2]
return
