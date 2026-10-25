function mut(x)
    AAdd(x, "tres")
return 0
function main()
    local a := {}
    AAdd(a, "uno")
    ? mut(a)
    ? len(a)
return nil
