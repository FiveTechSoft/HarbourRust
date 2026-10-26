procedure show(a)
    ? a[1] + "!"
    ? len(a)
return
function main()
    show({"x", "yy"})
    ? hb_memcheck()
return nil
