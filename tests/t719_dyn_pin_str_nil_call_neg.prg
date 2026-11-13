// pos (63u, updated by the args contract A1): an explicit NIL argument
// flips the parameter to the tagged union via nil_ev; the compare
// routes through Dyn and prints .F. for NIL == "ab", EXACTLY Harbour's
// hk272 (oracle-verified on the reference build; the old named
// rejection is gone).
procedure main()
   ? p( "ab" )
   ? p( nil )
   return
function p( x )
   return x == "ab"
