// Correctness-only interaction test, not a timed kernel.
function interact(n)
local a := {3,5,7,11}
local i := 0
local j := 1
local s := n+0
local b := .F.
for i := 1 to 12
j := hb_bitAnd(i,3)+1
b := Empty(hb_bitAnd(i,1)) .AND. (.NOT. Empty(a[j]))
if b .AND. (i < 10)
a[j] := Max(a[j],Min(s+i,100))
else
a[j] := hb_bitXor(a[j],i)
endif
if i == 4
loop
endif
s := (s++, s+a[j])
if (i > 8) .AND. (s > 200)
exit
endif
next
j := 1
while (j <= 4) .AND. (.NOT. Empty(a[j]))
s := s+a[j]
j += 1
enddo
return s+i+j
function main()
local n := 0
for n := -16 to 16
? interact(n)
next
return
