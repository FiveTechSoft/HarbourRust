// a move on a path that leaves via `exit` never reaches the next
// iteration, so it needs no reassignment (Rust accepts this too)
function main()
    local a := "hola"
    while 1 < 2
        local b := a
        ? b
        exit
    enddo
    ? "fuera"
return nil
