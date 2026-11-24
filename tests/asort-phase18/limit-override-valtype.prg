FUNCTION ValType(x)
RETURN "C"
FUNCTION Change(value, operation)
 IF ValType(operation)=="B"
  RETURN Eval(operation,value)
 ENDIF
RETURN value
FUNCTION Main()
 ? Change(7,{|n|n*2})
RETURN NIL
