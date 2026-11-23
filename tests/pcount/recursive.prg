function main()
? r(3)
? r(3,nil)
return nil
function r(n, spare)
local before, sub, after, result
before := pcount()
if n > 0
   sub := r(n-1)
else
   sub := 0
endif
after := pcount()
result := before * 100 + after + sub
return result
