// a nested collection a[1] is not iterable yet (named error; hk53/hk57 measured, support pending).
function main()
    local a := {{1, 2}, {3, 4}}
    local x := 0
    for each x in a[1]
        ? x
    next
return nil
