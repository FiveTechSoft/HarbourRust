// F(G(s), d) is no longer a false use after move; this shape is a real one: s is moved twice. Independent fixture.
function g(s)
return s + "!"
function f(a, x)
return a
function main()
local s := "a" + "b"
g(s)
g(s)
return nil
