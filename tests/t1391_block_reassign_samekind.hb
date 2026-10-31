function main()
    local b := {|| 11 }
    local c := {|| QOut("A") }
    local d := {|| QOut("A") }
    local i := 0
    b := {|| 22 }
    ? eval(b)
    if .t.
        c := {|| QOut("B") }
    endif
    ? eval(c)
    while i < 2
        d := {|| QOut("C") }
        i++
    enddo
    ? eval(d)
    return nil
