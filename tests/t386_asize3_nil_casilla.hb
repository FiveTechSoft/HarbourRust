// ASize on a NIL casilla is the registered BASE/2023 family failure mode (n7): clean exit 1.
function main()
    local a := {{{1, 2}}}
    ASize(a, 2)
    ASize(a[2], 1)
return nil
