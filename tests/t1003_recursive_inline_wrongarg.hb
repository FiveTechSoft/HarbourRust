function f(n)
return IIF(n<1,1,f("bad"))
function main()
? f(3)
return
