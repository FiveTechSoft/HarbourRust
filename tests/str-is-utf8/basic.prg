PROCEDURE Main()
 LOCAL i:=0,n:=0,s:=""
 ? hb_StrIsUTF8(""),hb_StrIsUTF8("abc"),hb_StrIsUTF8("á路径")
 FOR i:=0 TO 255
 FOR n:=0 TO 8
 s:=Chr(i)+Replicate(Chr(128),n)
 ? i,n,hb_StrIsUTF8(s)
 NEXT
 NEXT
RETURN
