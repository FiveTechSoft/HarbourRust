// the loop variable participates in Dyn+i64 arithmetic (read-only use).
function main()
    local a := {}
    local x := 0
    AAdd(a, 1)
    AAdd(a, 2)
    for each x in a
        ? x + 10
    next
return nil
