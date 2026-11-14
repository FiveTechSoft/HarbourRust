procedure Main()
   local th, r
   ? "join-ret", hb_threadJoin(hb_threadStart(@W()), @r)
   ? "r", r
return
function W()
return "hello"
