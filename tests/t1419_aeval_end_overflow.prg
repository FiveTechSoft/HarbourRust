// guardrail: start + count must not overflow before clamping;
// count i64::MAX from start 2 visits to the end.
function main()
   local a := { 10, 20, 30 }
   AEval(a, {|x,i| QOut(x,i)}, 2, 9223372036854775807)
   return nil
