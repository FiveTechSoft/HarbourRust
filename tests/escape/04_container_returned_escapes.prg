function build()
    local a := {}
    local i
    for i := 1 to 2
        AAdd(a, i * 10)
    next
return a

function main()
    local r := build()
    ? len(r)
return nil
