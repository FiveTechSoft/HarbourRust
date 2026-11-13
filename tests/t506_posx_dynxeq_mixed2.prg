// t506 (posx): an integer against a Dyn string casilla (literal on
// the LEFT) is Harbour's BASE/1070 condition (hk144: error dialog
// that hangs headless, no oracle) - a clean named exit 1 here,
// registered failure mode, NOT exact equivalence. Mirror direction
// of t504 (hk142).
function main()
    local h := {"b" => 20}
    local k := hb_HKeys(h)
    local c := 0
    for each c in k
        if 7 == c
            ? 1
        else
            ? 0
        endif
    next
return nil
