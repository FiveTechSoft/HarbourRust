procedure Main()
Work()
? hb_memcheck()
return
function Work()
? SubStr(Source(),Start(),Count())
return nil
function Source()
? "source"
return Replicate("ABC",2)
function Start()
? "start"
return 2
function Count()
? "count"
return 3
