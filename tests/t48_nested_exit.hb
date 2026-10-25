// exit binds to the innermost loop, for inside while and while inside for
function main()
    local k := 0
    while k < 2
        k := k + 1
        for i := 1 to 5
            if i = 2
                exit
            endif
            ? i
        next
        ? k
    enddo
    for j := 1 to 2
        local m := 0
        while m < 5
            m := m + 1
            if m = 2
                exit
            endif
            ? m
        enddo
        ? j
    next
return nil
