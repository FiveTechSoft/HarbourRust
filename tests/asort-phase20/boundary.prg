FUNCTION Modify(number, operation)
 IF ValType(operation)=="B"
  RETURN Eval(operation,number)
 ENDIF
RETURN number
FUNCTION Main()
 ? Modify(9223372036854775806,{|n|n+1})==9223372036854775807
 ? Modify(9223372036854775807,{|n|n-1})==9223372036854775806
 ? Modify(94906265,{|n|n*n})==9007199136250225
 ? Modify(9223372036854775807,{|n|(n-n)*2})==0
 ? Modify("s","notblock")
RETURN NIL
