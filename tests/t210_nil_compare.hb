// NIL comparisons (probe n1): NIL = NIL is .T.; NIL = 0 and "" = NIL are
// .F.; NIL != "" is .T. A NIL local keeps the sentinel through comparison.
function main()
local x := NIL
if NIL = 0
   ? "BAD1"
else
   ? "ok1"
endif
if NIL = NIL
   ? "ok2"
else
   ? "BAD2"
endif
if "" = NIL
   ? "BAD3"
else
   ? "ok3"
endif
if NIL != ""
   ? "ok4"
else
   ? "BAD4"
endif
if x = 0
   ? "BAD5"
else
   ? "ok5"
endif
if x = NIL
   ? "ok6"
else
   ? "BAD6"
endif
return nil
