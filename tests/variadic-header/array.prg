PROCEDURE Main()
 f(11,22,33)
 RETURN
FUNCTION f(a,...)
 LOCAL v := {...}
 ? Len(v)
 AEval(v,{|x|QOut(x)})
 RETURN NIL
