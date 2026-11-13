// ains 1b guardrails (verifier repros): named rejection, never a codegen panic
function main()
   local v := {||1}
   ? hb_isnumeric(v)
   return nil
