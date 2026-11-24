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
 ? Again(7),Again(5,NIL),Again("text",.F.),Again(.T.,"notblock")
 ? Again(9,{|n|n*n+2*n-1}),Relay(3,{|n|7}),Change(8,{|n|n+n})
RETURN NIL
