// step 0 would never advance: rejected at compile time
function main()
    for i := 1 to 3 step 0
        ? i
    next
return nil
