FUNCTION Change(value, operation)
 IF ValType(operation)=="B"
  RETURN Eval(operation,value)
 ENDIF
RETURN value
FUNCTION Relay(value, operation)
RETURN Change(value,operation)
FUNCTION Again(value,operation)
RETURN Relay(value,operation)
FUNCTION Main()
 ? Change(3,{|x|x+1,x*2})
 ? Again("s","notblock")
RETURN NIL
