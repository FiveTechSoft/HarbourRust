function Main()
Check()
OutStd('mem',hb_memcheck(),Chr(10))
return nil
function Check()
private s:='aBc',n:=3.555,d:=2
OutStd('up',&('Upper(s)'),Chr(10))
OutStd('lo',&('Lower(s)'),Chr(10))
OutStd('fold-extra',&('Upper("abc",missing)'),Chr(10))
OutStd('round',Str(&('Round(n,d)')),Chr(10))
OutStd('round-decfloat',Str(&('Round(n,2.9)')),Chr(10))
OutStd('round0',Str(&('Round(10,0)')),Chr(10))
OutStd('nested',&('Upper(Lower(s))'),Chr(10))
OutStd('roundnested',Str(&('Round(Round(n,d)/2,2)')),Chr(10))
OutStd('elide',&('.F. .AND. Upper(missing)'),&('Upper(missing) .AND. .F.'),Chr(10))
OutStd('comma',&('Upper((s,s))'),Chr(10))
OutStd('extra10',&('Upper(s,1,2,3,4,5,6,7,8,9,10)'),Chr(10))
return nil
