// growing the borrowed innermost child inside its loop could reallocate the borrowed cells.
function main()
    local a := {{{1, 2}}, {{3, 4}}}
    local x := 0
    for each x in a[1][1]
        AAdd(a[1][1], 9)
    next
return nil
