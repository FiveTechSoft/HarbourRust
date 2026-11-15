function Main()
private v:=10
public p:=40
OutStd('parent.before',&('v'),&('p'),'|',Chr(10))
Child()
OutStd('parent.after',&('v'),&('p'),'|',Chr(10))
return nil
function Child()
OutStd('child.inherited',&('v'),&('p'),'|',Chr(10))
private v:=20
OutStd('child.shadow',&('v'),'|',Chr(10))
Grand()
return nil
function Grand()
OutStd('grand.visible',&('v'),&('p'),'|',Chr(10))
return nil
