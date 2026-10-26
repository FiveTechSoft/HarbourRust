procedure main()
    local a := {"abc", "a", "abcd", "abc"}
    local c := ""
    for each c in a
        ? c < "abc", c > "abc", c <= "abc", c >= "abc"
    next
return
