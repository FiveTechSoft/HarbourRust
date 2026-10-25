// return inside an if block is rejected (return closes the function at its top level)
function main()
    if 1 < 2
        ? "x"
        return nil
    endif
return nil
