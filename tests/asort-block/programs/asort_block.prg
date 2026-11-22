function main()
 local a := {}
 local b := {}
 local c := {}
 local d := {}
 local e := {}
 local z := 3
 local f := {}
 local g := {}
 local h := {}
 AAdd(a, 3)
 AAdd(a, 1)
 AAdd(a, 2)
 AAdd(b, 3)
 AAdd(b, 1)
 AAdd(b, 2)
 AAdd(c, 1)
 AAdd(c, 3)
 AAdd(c, 2)
 AAdd(c, 9)
 AAdd(d, "b")
 AAdd(d, "a")
 AAdd(d, "c")
 AAdd(e, 2)
 AAdd(e, 5)
 AAdd(e, 1)
 AAdd(e, 4)
 AAdd(f, 1)
 AAdd(f, 4)
 AAdd(f, 2)
 AAdd(g, 5)
 AAdd(g, 2)
 AAdd(g, 8)
 AAdd(h, "a")
 AAdd(h, "B")
 AAdd(h, "c")
 ASort(a, , , {|x, y| x > y})
 ? a[1], a[2], a[3]
 ASort(b, , , {|x, y| x < y})
 ? b[1], b[2], b[3]
 ASort(c, 2, 2, {|x, y| x > y})
 ? c[1], c[2], c[3], c[4]
 ASort(d, , , {|x, y| x < y})
 ? d[1], d[2], d[3]
 ASort(e, nil, nil, {|x, y| x > y})
 ? e[1], e[2], e[3], e[4]
 ASort(f, , , {|x, y| x == z .or. y == z})
 ? f[1], f[2], f[3]
 ASort(g, , , {|x, y| x > y})
 ? ValType(g), Len(g)
 ASort(h, , , {|x, y| x < y})
 ? h[1], h[2], h[3]
return nil
