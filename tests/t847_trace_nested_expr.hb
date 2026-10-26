function value()
   if .T.
      return 7
   endif
return 0
function main()
   local d := 16
   ? value() + Round(value(),d)
return
