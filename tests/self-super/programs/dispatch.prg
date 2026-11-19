#include "hbclass.ch"
CREATE CLASS Base
 METHOD Ping()
 METHOD CallVirtual()
ENDCLASS
METHOD Ping() CLASS Base
 ? "base"
RETURN 1
METHOD CallVirtual() CLASS Base
RETURN ::Ping()
CREATE CLASS Child INHERIT Base
 METHOD Ping()
 METHOD ParentPing()
 METHOD ParentVirtual()
ENDCLASS
METHOD Ping() CLASS Child
 ? "child"
RETURN 2
METHOD ParentPing() CLASS Child
RETURN ::super:Ping()
METHOD ParentVirtual() CLASS Child
RETURN ::super:CallVirtual()
FUNCTION Main()
 LOCAL o := Child()
 ? "parent", o:ParentPing()
 ? "virtual", o:ParentVirtual()
 ? "normal", o:Ping()
RETURN NIL
