// AAdd on the middle level: pins element type of the middle child
function main()
    local a := {{{1, 2}}}
    local x := 0
    AAdd(a[1], {5, 6})
    ? len(a[1])
    for each x in a[1][2]
        ? x
    next
return nil
