// AAdd on a NIL middle casilla is the registered BASE/1123 family failure mode (n6): clean exit 1.
function main()
    local a := {{{1, 2}}}
    ASize(a, 2)
    AAdd(a[2], {5, 6})
return nil
