// returning the loop variable would escape a pointer borrowed from the collection - named error.
function main()
    local h := {"a" => 1}
    local k := hb_HKeys(h)
    local c := ""
    for each c in k
        return c
    next
return nil
