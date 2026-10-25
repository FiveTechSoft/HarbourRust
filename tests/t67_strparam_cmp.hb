// a string parameter is pinned by comparing it against a literal
function ishb(s)
    if s = "hb"
        return 1
    endif
    return 0

function main()
    ? ishb("hb")
    ? ishb("zz")
    return nil
