procedure Main()
? StrTran(Who(),"M","m")
? StrTran("abcabc","a","x",Where(),1)
return
function Who()
return ProcName(1)
function Where()
return ProcLine(1)-2
