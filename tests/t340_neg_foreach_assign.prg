// Harbour writes assignment THROUGH to the element (hk32); this increment rejects it - registered limitation.
function main()
    local a := {}
    local x := 0
    AAdd(a, 1)
    for each x in a
        x := 99
    next
return nil
