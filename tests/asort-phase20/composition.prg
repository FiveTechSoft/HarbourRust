FUNCTION Modify(number, operation)
 IF ValType(operation)=="B"
  RETURN Eval(operation,number)
 ENDIF
RETURN number
FUNCTION Main()
 ? Modify(9007199254740992,{|n|n*1+1})==9007199254740993
 ? Modify(9007199254740992,{|n|n*1-(-1)})==9007199254740993
 ? Modify(-9007199254740992,{|n|n*1-1})==-9007199254740993
 ? Modify(-9007199254740992,{|n|n*1+(-1)})==-9007199254740993
 ? Modify(9007199254740992,{|n|(n*1+1)-n})
 ? Modify(-9007199254740992,{|n|(n*1-1)-n})
RETURN NIL
