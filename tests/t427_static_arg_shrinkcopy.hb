function shrinkit(x)
    ASize(x, 2)
    ? len(x)
return 0
function work()
    local a := {1, 2, 3}
    ? shrinkit(a)
    ? len(a)
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
