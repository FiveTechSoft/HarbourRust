// integer and string parameters in one function
function pick(flag, s)
    if flag > 0
        if s = "a"
            return 7
        endif
    endif
    return 0

function main()
    ? pick(1, "a")
    ? pick(0, "a")
    return nil
