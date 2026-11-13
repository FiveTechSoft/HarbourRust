function main()
    // Our guard, no headless oracle (Harbour would attempt the allocation):
    // 1e18 elements * 16 bytes overflows i64 in hbc_asize -> clean OOM.
    local a := Array(1, 1000000000000000000)
    ? len(a)
return
