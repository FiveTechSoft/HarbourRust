procedure main()
    local h := {"b" => 20, "a" => 10}
    local k := hb_HKeys(h)
    local c := ""
    for each c in k
        if c < "b"
            ? "menor-que-b"
        else
            ? "no-menor"
        endif
    next
return
