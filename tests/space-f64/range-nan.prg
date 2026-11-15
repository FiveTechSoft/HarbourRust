procedure Main()
local e
try
? Len(Space((10.0^400)-(10.0^400)))
catch e
? "MUST_NOT_CATCH"
end
? "MUST_NOT_CONTINUE"
return
