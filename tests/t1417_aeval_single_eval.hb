// guardrail (verifier blocker on 573d572): start/count arguments with
// side effects evaluate EXACTLY ONCE and in argument order, before any
// element is visited.
function mark(n)
   ? n
   return n + 0
function main()
   local a := { 10, 20 }
   AEval(a, {|x,i| QOut(x,i)}, mark(1), mark(2))
   return nil
