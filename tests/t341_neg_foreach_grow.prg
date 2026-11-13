// growing the borrowed collection inside its own loop is rejected (borrowed pair would dangle).
function main()
    local a := {}
    local x := 0
    AAdd(a, 1)
    for each x in a
        AAdd(a, 2)
    next
return nil
