function main()
    // Oracle n2: len of a NIL casilla is Harbour's BASE/1111 (hangs
    // headless): clean error here, registered failure mode.
    local a := {{1, 2}, {3, 4}}
    ASize(a, 4)
    ? len(a[3])
return
