function main()
    local a := {}
    local i
    for i := 1 to 3
        local t := "x" + str(i)
        AAdd(a, t)
    next
    ? len(a)
return nil
