REQUEST DBFNTX
procedure Main()
local a:={{"CN","C",10,0},{"N2","N",8,2},{"N3","N",8,3},{"N0","N",6,0},{"NW","N",4,1},{"DD","D",8,0},{"LL","L",1,0}}
local e
RddSetDefault("DBFNTX")
dbCreate("corpus.dbf",a,"DBFNTX")
dbCreate("empty.dbf",a,"DBFNTX")
dbUseArea(.T.,"DBFNTX","corpus.dbf","DATA",.F.,.F.)
dbAppend()
FPut(1,"HELLO")
FPut(2,2.675)
FPut(3,2.675)
FPut(4,42)
FPut(5,1.5)
FPut(6,SToD("20260315"))
FPut(7,.T.)
dbAppend()
FPut(1,"TOOLONGSTRING1")
FPut(2,-0.5)
FPut(3,0.125)
FPut(4,-7)
FPut(5,-9.9)
FPut(6,SToD(""))
FPut(7,.F.)
dbAppend()
FPut(1,"")
FPut(2,123.456)
FPut(3,1/3)
FPut(4,1234567)
FPut(5,999.9)
FPut(6,SToD("19991231"))
FPut(7,.T.)
dbGoTop()
dbAppend()
FPut(2,FieldGet(3))
dbAppend()
FPut(2,2675/1000)
dbAppend()
FPut(2,7)
FPut(4,0)
FPut(3,0.0)
dbCloseArea()
return nil

procedure FPut(n,v)
local e
begin sequence with {|o| break(o) }
   FieldPut(n,v)
   ? "put",n,"ok"
recover using e
   ? "put",n,"ERR",e:genCode,e:subCode
end sequence
return
