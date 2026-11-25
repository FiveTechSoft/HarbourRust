PROCEDURE Main()
 LOCAL lead:=0,pos:=0,byte:=0,s:="",n:=0
 FOR lead:=192 TO 255
 n:=1
 IF lead>=224
 n:=2
 ENDIF
 IF lead>=240
 n:=3
 ENDIF
 IF lead>=248
 n:=4
 ENDIF
 IF lead>=252
 n:=5
 ENDIF
 IF lead>=254
 n:=6
 ENDIF
 IF lead==255
 n:=7
 ENDIF
 FOR pos:=1 TO n
 FOR byte:=0 TO 255
 s:=Chr(lead)+Replicate(Chr(128),pos-1)+Chr(byte)+Replicate(Chr(128),n-pos)
 ? lead,pos,byte,hb_StrIsUTF8(s)
 NEXT
 NEXT
 NEXT
RETURN
