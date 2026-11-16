function Main()
Check()
OutStd('mem',hb_memcheck(),Chr(10))
return nil
function Check()
local i:=0,result
private blank:='',s:='aBc',negative:=-3.555,ten:=10,dc:=2.9
OutStd('mixedcase',&('uPpEr(s)'),&('lOwEr(s)'),Chr(10))
OutStd('empty',&('Upper(blank)'),&('Lower(blank)'),Chr(10))
OutStd('nul',&('Upper("a'+Chr(0)+'b")'),Chr(10))
OutStd('ascii-range',&('Lower("@AZ[az{")'),&('Upper("@AZ[az{")'),Chr(10))
OutStd('minus',Str(&('Round(negative,dc)')),Str(&('Round(negative,-2.9)')),Chr(10))
OutStd('integer',Str(&('Round(ten,0)/2')),Chr(10))
OutStd('plus15',Str(&('Round(negative,15)')),Chr(10))
OutStd('minus15',Str(&('Round(negative,-15)')),Chr(10))
OutStd('bool',&('.T. .OR. Round(missing,2)'),&('Lower(missing) .OR. .T.'),Chr(10))
OutStd('nestedmacro',&('&("Upper(s)")'),Chr(10))
for i:=1 to 1000
result:=&('Upper(Lower(s))')
result:=&('Round(negative,2)')
next
return nil
