procedure main()
    local c := ""
    for each c in hb_HKeys({"b" => 20, "a" => 10})
        if c = "a"
            exit
        endif
        ? c
    next
    ? "fin"
return
