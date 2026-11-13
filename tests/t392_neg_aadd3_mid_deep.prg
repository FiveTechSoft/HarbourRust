// a nested literal element would make a fourth level: named compile error.
function main()
    local a := {{{1, 2}}}
    AAdd(a[1], {{9}})
return nil
