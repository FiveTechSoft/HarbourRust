PROCEDURE Main(c)
? Empty(c),ValType(c)
IF Empty(c)
 c:="/tmp"
ENDIF
? hb_DiskSpace(c,0)
c:=Lower("/TMP")
? hb_DiskSpace(c,0)
c:=" "
? hb_DiskSpace(c,0)
c:=""
? hb_DiskSpace(c,0)
c:="/tmp"
? hb_DiskSpace(c,0),hb_DiskSpace(c,1),hb_DiskSpace(c,2),hb_DiskSpace(c,3)
c:=Upper("/tmp")
? hb_DiskSpace(c,0)
RETURN
