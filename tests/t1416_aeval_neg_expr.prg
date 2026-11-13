// neg: AEval in expression position is rejected (the array it returns
// needs alias semantics, registered limit).
function main()
   local a := { 1, 2 }
   local b := {|x,i| x }
   local x := AEval(a, b)
   return nil
