function main()
    // Oracle n6: AAdd on a NIL casilla is Harbour's BASE/1123 (hangs
    // headless): clean error here, registered failure mode.
    local a := {{1}, {2}}
    ASize(a, 3)
    AAdd(a[3], 5)
return
