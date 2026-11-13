function main()
    // Oracle n7: ASize on a NIL casilla is Harbour's BASE/2023 (hangs
    // headless): clean error here, registered failure mode.
    local a := {{1}, {2}}
    ASize(a, 3)
    ASize(a[3], 2)
return
