// neg: the same variable cannot move twice in one expression
function isab(s)
    if s = "ab"
        return 1
    endif
    return 0

function main()
    local v := "ab"
    ? isab(v) + isab(v)
    return nil
