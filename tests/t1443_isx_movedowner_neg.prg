// ains 1b guardrails (verifier repros): named rejection, never a codegen panic
function main()
   local a := {1,"x",NIL}
   local c := a
   ? hb_isarray(a)
   return nil
