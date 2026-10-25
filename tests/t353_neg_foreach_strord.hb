// ordering against the loop variable: Harbour orders string elements (hk36) - measured, pending; named error for now.
function main()
    local h := {"a" => 1}
    local k := hb_HKeys(h)
    local c := ""
    for each c in k
        if c < "b"
            ? "menor"
        endif
    next
return nil
