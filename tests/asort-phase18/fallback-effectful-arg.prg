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
 LOCAL n:=3
 ? Change(n++,{|x|x*2})
 ? Again("s","notblock")
RETURN NIL
