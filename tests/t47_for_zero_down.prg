// zero-trip downward loop (start < end with a negative step)
function main()
    for i := 1 to 3 step -1
        ? i
    next
    ? "fin"
return nil
