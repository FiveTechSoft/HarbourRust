function mark(n)
? n
return n+0
function probe(n)
local outer := {1,2}
local i := 0
if n+0 == 0
local a := {mark(1),mark(2)}
? len(a),a[1],a[2]
else
local a := {mark(3),mark(4),mark(5)}
? len(a),a[1],a[3]
endif
if n+0 == 0
local mixed := {7,8}
? mixed[2]
else
local mixed := .T.
? mixed
endif
for i := 1 to 3
local a := {i,i+1}
a := {a[2],a[1]}
if i == 2
loop
endif
? a[1],a[2]
next
? i,outer[1],outer[2]
for j := mark(1) to mark(2)
local a := {j,j*2,j*3}
? len(a),a[3]
next
if n+0 == 0
local j := {9,10}
? j[2]
else
local j := 11
? j
endif
if n+0 == 0
local reverse := 17
? reverse
else
local reverse := {18,19}
? reverse[1]
endif
local w := 0
while w < 2
w += 1
if w == 1
local nested := {12,13}
? nested[2]
else
local nested := {14,15,16}
? nested[3]
endif
enddo
return 0
function main()
? probe(0),probe(1)
return
