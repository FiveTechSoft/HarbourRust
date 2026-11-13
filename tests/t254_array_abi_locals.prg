function main()
    // Regression: live Harbour-level state must survive helper calls
    // (hbc_arraym -> hbc_asize/hbc_aadd, plus direct AAdd/ASize).
    // a[1][4] expectation grounded in oracle anadd. Caught the Windows helpers clobbering callee-saved registers when
    // hbc_arraym kept its loop state in them.
    local x := 11
    local y := 22
    local z := 33
    local a := Array(2, 3)
    local w := x + y
    AAdd(a[1], 7)
    ASize(a, 4)
    ? x + y + z
    ? w
    ? len(a)
    ? a[1][4]
return
