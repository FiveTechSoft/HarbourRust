procedure main()
    local a := {"abc", "ab", "abd", "abb"}
    local c := ""
    ? "-- vs 'ab' --"
    for each c in a
        ? c < "ab", c > "ab", c <= "ab", c >= "ab"
    next
    ? "-- vs 'abc' --"
    for each c in a
        ? c < "abc", c > "abc"
    next
    ? "-- empty right --"
    ? c > "", c < "", c = ""
return
