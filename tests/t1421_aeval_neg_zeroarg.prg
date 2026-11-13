// neg: AEval() reaches the precise arity rejection, not the generic
// unknown-function error.
function main()
   local a := { 1 }
   AEval()
   return nil
