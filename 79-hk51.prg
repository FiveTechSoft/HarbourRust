procedure main()
    local a := {"abc", "ab", "abd", "b"}
    local c := ""
    ? "-- 'ab' OP c --"
    for each c in a
        ? "ab" < c, "ab" > c, "ab" <= c, "ab" >= c
    next
    ? "-- 'b' OP c --"
    for each c in a
        ? "b" < c, "b" > c
    next
return
