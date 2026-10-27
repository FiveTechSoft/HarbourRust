function bump(n)
? n
return n+1
function main()
local i := 0
local j := 0
local x := 0
local b := .T.
for i := 1 to i+2
x += i
next
? x, i
for i := 2 to ++i
x += i
next
? x, i
for i := 4 to i-3 step -1
x += i
next
? x, i
? "a  ", "z  "
?? "keep", "  "
? "", "x  "
? If(.T., 1, ++x), If(.F., ++x, 2), x
? bump(1), bump(2)
if b
local scoped := 7
? scoped
else
local scoped := 8
? scoped
endif
while i < 2
i += 1
? i
enddo
return
