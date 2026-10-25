// exit leaves the for loop; loop skips to the next iteration (advancing i)
function main()
    for i := 1 to 10
        if i = 2
            loop
        endif
        if i = 5
            exit
        endif
        ? i
    next
    ? "fuera"
return nil
