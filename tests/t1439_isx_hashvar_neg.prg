// ains 1b guardrails (verifier repros): named rejection, never a codegen panic
function main()
   local v := {"a"=>1}
   ? hb_isarray(v)
   return nil
