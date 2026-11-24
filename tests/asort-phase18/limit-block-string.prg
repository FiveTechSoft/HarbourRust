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
 ? Change("s",{|x|x*2})
 ? Again("s","notblock")
RETURN NIL
