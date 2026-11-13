// neg: an integer where the callee expects a string
function isab(s)
    if s = "ab"
        return 1
    endif
    return 0

function main()
    ? isab(5)
    return nil
