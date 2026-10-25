// since iteration 7: an early `return <expr>` inside an if block closes the
// function at once; the closing top-level return is still required
function pick()
    local x := 5
    if x > 1
        return 100
    endif
    x := x + 1
    return x
function main()
    ? pick()
return nil
