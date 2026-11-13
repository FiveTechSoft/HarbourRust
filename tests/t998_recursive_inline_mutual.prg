function a(n)
return IIF(n<1,1,n*b(n-1))
function b(n)
return IIF(n<1,1,n*a(n-1))
function main()
? a(10),b(9)
return
