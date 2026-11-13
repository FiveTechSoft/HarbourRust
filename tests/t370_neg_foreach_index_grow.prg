// the root collection cannot be grown inside its own loop (the loop borrows it).
function main()
    local a := {{1, 2}, {3, 4}}
    local x := 0
    for each x in a[1]
        ASize(a, 3)
    next
return nil
