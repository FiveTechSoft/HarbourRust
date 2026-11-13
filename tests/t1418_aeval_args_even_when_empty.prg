// guardrail: every argument evaluates once in order even when a
// negative start means no iteration at all.
function mark(n)
   ? n
   return n + 0
function main()
   local a := { 10, 20 }
   AEval(a, {|x,i| QOut(x,i)}, mark(-1), mark(2))
   ? "done"
   return nil
