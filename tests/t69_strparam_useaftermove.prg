// neg: a moved string variable cannot be used again
function isab(s)
    if s = "ab"
        return 1
    endif
    return 0

function main()
    local v := "ab"
    ? isab(v)
    ? v
    return nil
