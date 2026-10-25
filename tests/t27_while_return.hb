// return inside a while block is rejected (return closes the function at its top level)
function main()
    while 1 < 2
        ? "x"
        return nil
    enddo
return nil
