// empty array: zero iterations, loop variable restored (oracles hk28/hk29).
function main()
    local a := {}
    local x := 42
    for each x in a
        ? x
    next
    ? x
return nil
