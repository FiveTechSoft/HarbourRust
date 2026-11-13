// writing through the root inside the loop is rejected like any other borrowed-collection mutation.
function main()
    local a := {{{1, 2}}, {{3, 4}}}
    local x := 0
    for each x in a[1][1]
        a[1][1][1] := 9
    next
return nil
