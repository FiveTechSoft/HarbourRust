// ains 1b guardrails (verifier repros): named rejection, never a codegen panic
function main()
   local x := NIL
   ? hb_isarray(x)
   return nil
