// the collection index expression evaluates ONCE, effects included.
function ni()
    ? "eval"
return 2
function main()
    local a := {{1, 2}, {3, 4}}
    local x := 0
    for each x in a[ni()]
        ? x
    next
return nil
