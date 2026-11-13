// AAdd on the middle with a DYNAMIC array value (call result)
function main()
    local a := {{{1, 2}}}
    local x := 0
    AAdd(a[1], Array(2))
    ? len(a[1])
    ? len(a[1][2])
    ? a[1][2][1]
return nil
