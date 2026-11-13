function f(n)
return IIF(n<1,"yes",f(n-1))
function main()
? f(3)
return
