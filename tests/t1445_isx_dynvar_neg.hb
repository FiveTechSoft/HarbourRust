// ains 1b guardrails (verifier repros). WAS a named rejection pre-P2
// ("hb_isarray over a Dyn variable is not measured"); since ains P2
// stage 1 HB_ISARRAY over a Dyn variable IS measured (tag 6 or 8) -
// positive fixture, oracle-verified .F. on a NIL Dyn.
function main()
   local x := NIL
   ? hb_isarray(x)
   return nil
