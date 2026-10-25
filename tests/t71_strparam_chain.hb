// a parameter pinned through another function's signature
function isab(s)
    if s = "ab"
        return 1
    endif
    return 0

function wrap(s)
    return isab(s)

function main()
    ? wrap("ab")
    return nil
