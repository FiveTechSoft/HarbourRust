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
 ? Change(3,{|x|x*2},9)
 ? Again("s","notblock")
RETURN NIL
