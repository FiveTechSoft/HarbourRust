procedure main()
    local h := {"a" => 1}
    local k := hb_HKeys(h)
    local c := ""
    ASize(k, 2)
    for each c in k
        if c = "a"
            ? "igual-a"
        else
            ? "no-a"
        endif
        if c <> "a"
            ? "distinto-de-a"
        endif
    next
return
