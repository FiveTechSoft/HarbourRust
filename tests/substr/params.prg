function Main()
? Slice("ABCDE",2,3)
? Slice(Replicate("AB",4),-3,2)
return nil
function Slice(s,n,k)
return SubStr(s,n,k)
