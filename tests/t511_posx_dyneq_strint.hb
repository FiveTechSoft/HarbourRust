// t511: `=` between a string casilla and an integer casilla is Harbour's
// BASE/1071 "Argument error: =" (oracle hk146 - the dialog hangs
// headless, so there is no headless oracle): clean named exit 1 here,
// registered failure mode, not exact equivalence.
function main()
    local h := {"a" => 1}
    local a := {7}
    local k := hb_HKeys(h)
    local c := 0
    for each c in k
        if c = a[1]
            ? 1
        else
            ? 0
        endif
    next
return nil
