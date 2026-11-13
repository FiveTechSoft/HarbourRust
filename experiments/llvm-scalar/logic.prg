// Exhaustive truth table and side effects, using the existing I64 ABI.
function mark(n)
? n
return n+0
function logiccode(n,m,k)
local x := n+0
local y := m+0
local z := k+0
return If((x > 0) .AND. (y > 0),1,0) + 2*If((x > 0) .OR. (y > 0),1,0) + 4*If(.NOT. (x > 0),1,0) + 8*If(.NOT. ((x > 0) .OR. ((y > 0) .AND. (z > 0))),1,0) + 16*If((x > 0) .AND. (.NOT. (y > 0) .OR. (z > 0)),1,0)
function main()
local i := 0
local j := 0
local k := 0
local b := .F.
local a := {7,8,9}
local bad := 0
for i := 0 to 1
for j := 0 to 1
for k := 0 to 1
? If((i == 1) .AND. (j == 1),1,0), If((i == 1) .OR. (j == 1),1,0)
? If(.NOT. (i == 1),1,0), If(.NOT. ((i == 1) .OR. ((j == 1) .AND. (k == 1))),1,0)
b := (i == 1) .AND. (.NOT. (j == 1) .OR. (k == 1))
? If(b,1,0)
next
next
next
for i := -1 to 1
for j := -1 to 1
for k := -1 to 1
? logiccode(i,j,k)
next
next
next
i := 0
// Skipped increment and out-of-range access must not run.
? If(.F. .AND. (++i > 0),1,0), i
? If(.T. .OR. (++i > 0),1,0), i
? If(.F. .AND. (a[bad] == 1),1,0)
? If(.T. .OR. (a[bad+4] == 1),1,0)
// Taken RHS, value-context normalization, left-to-right call effects.
? If(.T. .AND. (++i > 0),1,0), i
? If(.F. .OR. (++i > 0),1,0), i
? If((mark(1) == 1) .AND. (mark(2) == 2),1,0)
? If((mark(3) == 3) .OR. (mark(4) == 4),1,0)
? If((mark(5) == 0) .AND. (mark(6) == 6),1,0)
? If((mark(7) == 0) .OR. (mark(8) == 8),1,0)
i := 0
while (i < 3) .AND. (a[i+1] > 0)
i += 1
enddo
? i
return
