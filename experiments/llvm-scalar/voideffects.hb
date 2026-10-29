procedure leaf(n)
?? n+0
return
procedure recurse(n)
if n+0 > 0
recurse(n-1)
endif
leaf(n+0)
return nil
procedure early(n)
local i := 0
for i := 1 to 3
if i == n+0
?? "early", i
return
endif
next
?? "end"
return
procedure ping(n)
if n+0 > 0
pong(n-1)
endif
return
procedure pong(n)
if n+0 > 0
ping(n-1)
endif
?? "pong"
return
procedure main()
recurse(2)
early(2)
early(8)
ping(2)
return
