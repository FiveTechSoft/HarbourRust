// guardrail: generated desugar temporaries can never collide with a
// user local (line 4 is the AEval call; the old __aeval_s_4 name would
// have been a duplicate-local error).
function main()
   local __aeval_s_4 := 99
   local a := { 10, 20 }
   AEval(a, {|x,i| QOut(x,i) })
   ? __aeval_s_4
   return nil
