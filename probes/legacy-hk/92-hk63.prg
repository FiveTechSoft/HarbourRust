// NIL inner casilla at depth 3: what error?
function main()
    local a := {{{1, 2}}}
    local x := 0
    ASize(a[1], 2)
    for each x in a[1][2]
        ? x
    next
return nil
