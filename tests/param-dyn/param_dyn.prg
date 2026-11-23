function main()
local i, b, a, s
? f("2024")
? f("7")
? g("12.5")
? rec("5", 4)
? dates("2024")
work()
b := hb_memcheck()
for i := 1 to 20
   work()
next
a := hb_memcheck()
if a == b
   ? "balanced"
else
   ? "LEAK", a - b
endif
return nil

function work()
local i, a, s
for i := 1 to 200
   s := "20" + str(i % 10, 1)
   a := f(s)
   a := f("2024")
   a := g("3")
next
return nil

function f(cYEAR)
local x
cYEAR := val(cYEAR)
x := cYEAR + 1
return x

function g(cN)
local y
cN := val(cN)
y := cN * 2
return y

function rec(c, n)
local r, t
if n > 0
   t := c + ""
   r := rec(t, n - 1)
else
   r := 0
endif
c := val(c)
r := c + r
return r

function dates(c)
local d := ctod(""), s, r
s := "01/01/" + c
set date american
d := ctod(s)
c := val(c)
r := year(d)
return r
