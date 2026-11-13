// string on the LEFT, and an owned temporary read (k[1]) as the string side - freed after the comparison.
function main()
    local h := {"a" => 1}
    local k := hb_HKeys(h)
    local c := ""
    for each c in k
        if "a" = c
            ? "igual"
        endif
        if k[1] = c
            ? "igual-temp"
        endif
    next
return nil
