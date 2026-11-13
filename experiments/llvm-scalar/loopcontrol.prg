// EXIT and LOOP target the innermost construct. No collection ownership.
function early(n)
local i := 0
for i := 1 to n+0
if i == 2
return i
else
loop
endif
next
return i
function main()
local i := 0
local j := 0
local k := 0
local a := {10,20,30}
for i := 1 to 5
if i == 2
loop
endif
if i == 4
exit
endif
? i, a[i]
next
? i
for i := 4 to 1 step -1
if i == 3
loop
endif
if i == 1
exit
endif
? i
next
? i
i := 0
while i < 5
i += 1
if i == 2
loop
endif
if i == 4
exit
endif
? i
enddo
? i
// Both IF arms terminate the body: no extra branch after a terminator.
for i := 1 to 4
if i < 3
loop
else
exit
endif
? a[9+i]
next
? i
// Nested FOR/WHILE and WHILE/FOR; continue must not escape outward.
for i := 1 to 2
j := 0
while j < 4
j += 1
if j == 2
loop
endif
if j == 3
exit
endif
? i,j
enddo
? i,j
next
k := 0
while k < 2
k += 1
for j := 1 to 4
if j == 2
loop
endif
if j == 3
exit
endif
? k,j
next
? k,j
enddo
// LOOP must reach the checked increment, preserving the old max counter.
for i := 9223372036854775807 to 9223372036854775807
loop
next
? i
local low := -9223372036854775807
low -= 1
for i := low to low step -1
loop
next
? i
for i := 3 to 2
exit
next
? i, early(4), early(0)
return
