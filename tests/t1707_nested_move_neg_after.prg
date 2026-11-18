// F(G(s), d) is no longer a false use after move; this shape is a real one: s is read after the call that moved it. Independent fixture.
function g(s)
return s + "!"
function f(a, x)
return a
function main()
local s := "a" + "b"
f(g(s), 1)
? s
return nil
