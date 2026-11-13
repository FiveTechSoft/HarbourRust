function before(x)
   local r := QQOut(x)
return x+1
function after(x)
   local n := x+1
   local r := QQOut(x)
return n
function strbefore(x)
   local r := QQOut(x)
   if x == "A"
      return 1
   endif
return 0
function main()
   ? before(4), after(4), strbefore("A")
return
