function main()
    local a := {}
    local i
    for i := 1 to 5
        local t := "z" + str(i)
        if i == 3
            exit
        endif
        AAdd(a, t)
    next
    ? len(a)
return nil
