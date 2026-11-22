function main()
 local n := 0
 local x
 local a := {1, 2, 3}
 local w
 local y
 local b := {10, 20, 30, 40}
 local acc := ""
 for each x in a
    n := n + x
 next
 ? n
 for each x in b
    if x > 15
        w := x
        ? w
    endif
 next
 for each x in a
    ? x, ValType(x)
 next
 n := 0
 for each x in a
    n := n + x
    if n > 5
        exit
    endif
 next
 ? n
 for each y in a
    acc := acc + Str(y, 2)
 next
 ? "[" + acc + "]"
return nil
