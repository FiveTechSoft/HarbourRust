function Work()
local original := hb_jsonDecode('["one",["two",[3,4,5,6,7]],[]]')
local i
for i := 1 to 5
TRY
Break(original)
CATCH caught
? hb_jsonEncode(caught)
END
? hb_jsonEncode(original)
next
return nil

function Main()
Work()
? "done"
return nil
