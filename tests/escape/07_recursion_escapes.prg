function walk(n, acc)
    if n <= 1
        return len(acc)
    endif
    local d := walk(n - 1, acc)
return d + 1

function main()
    local a := {}
    AAdd(a, 5)
    ? walk(3, a)
return nil
