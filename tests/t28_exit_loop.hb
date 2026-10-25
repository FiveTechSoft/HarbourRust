// exit leaves the innermost while; loop skips to the next iteration
function main()
    local i := 1
    while i <= 10
        if i = 3
            exit
        endif
        ? i
        i := i + 1
    enddo
    ? "salido"
    local j := 0
    while j < 5
        j := j + 1
        if j = 2
            loop
        endif
        if j = 4
            loop
        endif
        ? j
    enddo
    ? "fin"
return nil
