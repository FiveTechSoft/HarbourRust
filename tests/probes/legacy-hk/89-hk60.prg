// for each over a[i][j] on a three-level array
function main()
    local a := {{{1, 2}}, {{3, 4}}}
    local x := 0
    for each x in a[1][1]
        ? x
    next
    for each x in a[2][1]
        ? x
    next
return nil
