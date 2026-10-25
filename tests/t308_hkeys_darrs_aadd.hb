// {} grown with string elements pins an array of strings (DArrS): same
// mutation behaviour as an hb_HKeys result (grounded in oracle hk7).
// AAdd(a, a[2]) self-inserts: the read COPIES, so the append is an
// independent owned string. Registry balance 0 (wrap pattern).
function wrap()
    local a := {}
    AAdd(a, "x")
    AAdd(a, "yy")
    ? len(a)
    ? a[1]
    ? a[2]
    a[1] := "zzz"
    ? a[1]
    AAdd(a, a[2])
    ? a[3]
return 0
function main()
    ? wrap()
    ? hb_memcheck()
return nil
