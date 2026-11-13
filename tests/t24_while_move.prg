// moving an outer string inside the body without reassigning it before
// enddo is rejected (the next iteration would use a moved value)
function main()
    local a := "hola"
    local i := 0
    while i < 2
        local b := a
        ? b
        i := i + 1
    enddo
return nil
