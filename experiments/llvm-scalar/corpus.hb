function sumloop(n)
local i := 0
local s := 0
for i := 1 to n
s += 5
next
return s + i
function branchloop(n)
local i := 0
local s := 0
for i := 1 to n
if i < n - 7
s += 3
else
s += 1
endif
next
return s + i
function fact(n)
return If(n < 2, 1, n * fact(n-1))
function recurrence(n)
local i := 0
local s := 1
for i := 1 to n
s := s * 3 + i
next
return s
function main()
? sumloop(1000000), branchloop(1000000), fact(10), recurrence(20)
return
function boolflip(b)
return .NOT. b
function voideffect(n)
local i := 0
for i := 1 to n
if i == 2
return
endif
next
return nil
function voidlogical(b)
if .NOT. b
return
endif
return nil
