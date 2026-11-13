function main()
    // Oracle pr7c: Array(0, -1, 3) raises BASE/1131 in Harbour even when
    // the outer count is 0 (the error dialog hangs headless). hbc exits
    // cleanly on the same condition.
    local a := Array(0, -1, 3)
    ? len(a)
return
