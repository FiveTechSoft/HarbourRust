// t504 (posx): `==` between a Dyn string casilla and an integer is
// Harbour's BASE/1070 condition (hk142, and hk139/hk139b/hk139c for
// the cell shapes: error dialog that hangs headless, no oracle) - a
// clean named exit 1 here, registered failure mode, NOT exact
// equivalence.
function main()
    local h := {"b" => 20}
    local k := hb_HKeys(h)
    local c := 0
    for each c in k
        if c == 7
            ? 1
        else
            ? 0
        endif
    next
return nil
