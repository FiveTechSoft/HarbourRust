function main()
   ErrorBlock({|e| OnError(e)})
   ? Asc(65), Asc(NIL), Asc(.T.), Asc({65})
return
function OnError(e)
   ? "ERR", e:subCode, e:operation
return 777
