#include "trace-include.ch"
function descend(n)
local v := 9223372036854775807
return If(n < 1, 1, n*descend(n-1) + ++v)
function main()
? descend(4)
return
