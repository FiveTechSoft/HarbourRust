// loop skips to the next iteration of the innermost loop only
function main()
    for i := 1 to 3
        for j := 1 to 3
            if j = 2
                loop
            endif
            ? j
        next
        ? i
    next
return nil
