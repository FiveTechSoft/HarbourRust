function f(n)
return IIF(n<1,1.25,f(n-1)+1.0)
function main()
? f(3)
return
