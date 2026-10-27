function f(n)
if n<1
return 1
endif
return IIF(n<2,2,f(n-1)+1)
function main()
? f(4)
return
