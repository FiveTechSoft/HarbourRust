function main()
    local h := {"b" => 20, "a" => 10}
    local k := hb_HKeys(h)
    local c1, c2
    for each c1 in k
        for each c2 in k
            ? c1 == c2
        next
    next
return nil
