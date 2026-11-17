EXTERNAL HBR_HALF,HBR_EVAL

// EXTERNAL calls from concurrent threads, including a C function that
// evaluates an hbc codeblock (callback into hbc on the calling thread).
procedure Main()
   local t := {}, i, r
   for i := 1 to 4
      AAdd(t, hb_threadStart(@Work()))
   next
   for i := 1 to 4
      hb_threadJoin(t[i], @r)
      ? "thread", i, r
   next
   ? "main", Work()
return

function Work()
   local i, n := 0, b := {|x, y| x + y}
   for i := 1 to 2000
      n := n + HBR_HALF(i * 2) + HBR_EVAL(b)
   next
return n
