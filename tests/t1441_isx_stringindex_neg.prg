// ains 1b guardrails (verifier repros): named rejection, never a codegen panic
function main()
   local a := {1,"x",NIL}
   ? hb_isnumeric(a["x"])
   return nil
