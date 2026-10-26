procedure use()
    local a := {"a", "bb", "ccc"}
    ? len(a)
    ? a[1] + a[2] + a[3]
    aadd(a, "dddd")
    ? len(a)
    ? a[4]
    ? valtype(a)
    ? valtype(a[1])
return
function main()
    use()
    ? hb_memcheck()
return nil
