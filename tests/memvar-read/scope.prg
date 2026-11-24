MEMVAR shared
PROCEDURE Setup()
 PUBLIC shared:="public"
RETURN
PROCEDURE Read()
 LOCAL shared:="local"
 ? shared,M->shared,MEMVAR->shared
RETURN
PROCEDURE Shadow()
 PRIVATE shared:="private"
 Read()
RETURN
PROCEDURE Main()
 Setup()
 Read()
 Shadow()
 Read()
RETURN
