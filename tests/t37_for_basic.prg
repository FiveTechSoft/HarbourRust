// for i := start to end [step n]: up, stepped, counted down, zero-trip
function main()
    for i := 1 to 3
        ? i
    next
    for j := 1 to 5 step 2
        ? j
    next
    for k := 3 to 1 step -1
        ? k
    next
    for m := 5 to 1
        ? m
    next
    ? "fin"
return nil
