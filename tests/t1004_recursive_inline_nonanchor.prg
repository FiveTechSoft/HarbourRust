function f(n)
return IIF(n<1,g(n),f(n-1))
function g(n)
return n+1
function main()
? f(3)
return
