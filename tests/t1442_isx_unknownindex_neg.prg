// ains 1b guardrails (verifier repros): named rejection, never a codegen panic
function main()
   local a := {1,"x",NIL}
   ? hb_isnumeric(a[nosuchfn_xyzzy()])
   return nil
