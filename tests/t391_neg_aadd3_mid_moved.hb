// reusing the source after it moved into the middle level is a clean error.
function main()
    local a := {{{1, 2}}}
    local b := {}
    AAdd(b, 7)
    AAdd(a[1], b)
    ? len(b)
return nil
