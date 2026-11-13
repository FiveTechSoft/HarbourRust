// since iteration 7: an early `return <expr>` inside a while block works too
function findover()
    local i := 0
    while i < 100
        i := i + 7
        if i > 20
            return i
        endif
    enddo
    return 0
function main()
    ? findover()
return nil
