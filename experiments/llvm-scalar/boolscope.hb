function probe(n)
local outer := .T.
if n+0 == 0
local item := .T.
? item
else
local item := 7
? item
endif
? outer
if n+0 == 0
local other := 8
? other
else
local other := .F.
? other
endif
if outer
local nested := .T.
if n+0 == 1
local inner := .F.
? inner,nested
else
local inner := 9
? inner,nested
endif
endif
return 0
function main()
? probe(0),probe(1)
return
