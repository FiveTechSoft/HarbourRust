// while/enddo: counting loop, zero-trip loop, if inside the body
function main()
    local i := 1
    while i <= 3
        ? i
        if i = 2
            ? "dos"
        endif
        i := i + 1
    enddo
    ? "fin"
    local j := 5
    while j < 0
        ? j
        j := j + 1
    enddo
    ? "cero viajes"
return nil
