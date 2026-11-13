// a literal argument has no owner to move from
function isab(s)
    if s = "ab"
        return 1
    endif
    return 0

function main()
    ? isab("ab")
    ? isab("ab")
    return nil
