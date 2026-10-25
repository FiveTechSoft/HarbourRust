function f(n)
    ? "f"
return n + 0
function g(n)
    ? "g"
return n + 0
function main()
    // Oracle aevord: dimensions evaluate left to right, each exactly once.
    local a := Array(f(2), g(3))
    ? len(a)
    ? len(a[1])
return
