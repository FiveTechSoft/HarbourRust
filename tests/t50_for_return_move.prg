// conservative join, documented: the move only happens on a path that
// returns, but the checker joins both if branches and requires the
// reassignment anyway (Rust accepts this program; this PoC rejects it)
function f()
    local a := "x"
    for i := 1 to 3
        if i = 2
            return a
        endif
    next
    return 0
function main()
    ? f()
return nil
