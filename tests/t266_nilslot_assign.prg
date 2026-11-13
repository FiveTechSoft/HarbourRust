function main()
    // Oracle n3: assigning an array into a NIL casilla works; the
    // sibling casilla stays NIL. An empty assign + AAdd also works.
    local a := {{1, 2}, {3, 4}}
    ASize(a, 4)
    a[3] := {9, 9}
    ? a[3][1]
    ? len(a[3])
    ? a[4]
    a[4] := {}
    AAdd(a[4], 5)
    ? len(a[4])
    ? a[4][1]
return
