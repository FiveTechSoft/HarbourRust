// pos (63u, updated by the args contract A1): an explicit NIL argument
// is the same boundary event as an omitted one - nil_ev flips the
// parameter to the tagged union, the compare routes through Dyn and
// prints .F. for NIL = 5, EXACTLY Harbour's hk271 (oracle-verified on
// the reference build; the old extraction-failure divergence is gone).
procedure main()
   ? p( 5 )
   ? p( 4 )
   ? p( nil )
   return
function p( x )
   return x = 5
