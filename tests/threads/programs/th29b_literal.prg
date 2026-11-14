procedure Main()
   local th, r
   th := hb_threadStart(@W(), "literal-arg")
   hb_threadJoin(th, @r)
   ? "got", r
return
function W(s)
return s
