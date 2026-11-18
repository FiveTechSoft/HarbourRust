// F(G(s), d) is no longer a false use after move; this shape is a real one: s is moved in a loop and not reassigned. Independent fixture.
function g(s)
return s + "!"
function f(a, x)
return a
function main()
local s := "a" + "b", d
for d := 1 to 3
f(g(s), 1)
next
return nil
