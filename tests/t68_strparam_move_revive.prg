// a string argument MOVES out of the caller's variable; it can be
// re-initialized afterwards (assignment re-lives it)
function isab(s)
    if s = "ab"
        return 1
    endif
    return 0

function main()
    local v := "ab"
    ? isab(v)
    v := "zz"
    ? v
    return nil
