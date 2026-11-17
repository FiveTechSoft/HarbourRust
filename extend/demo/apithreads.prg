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
   ? "half", HBR_HALF(2000)
return

function Work()
   local i, n := 0, h, b := {|x, y| x + y}
   for i := 1 to 2000
      if HBR_EVAL(b) == 13
         n++
      endif
      h := HBR_HALF(i)
   next
return n
