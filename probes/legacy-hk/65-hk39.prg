procedure main()
    local a := {"b", "a", "c"}
    local c := ""
    for each c in a
        ? c > "b", c < "b", c <= "b", c >= "b"
    next
return
