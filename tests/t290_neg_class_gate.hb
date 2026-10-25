CREATE CLASS TCounter
   DATA n
   METHOD New() CONSTRUCTOR
   METHOD Inc()
   METHOD Get()
ENDCLASS
METHOD New() CLASS TCounter
   ::n := 0
return Self
METHOD Inc() CLASS TCounter
   ::n := ::n + 1
return Self
METHOD Get() CLASS TCounter
return ::n
function main()
   local o := TCounter():New()
   o:Inc()
   ? o:Get()
return
