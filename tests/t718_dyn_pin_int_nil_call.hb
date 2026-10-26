// posx 1 (63u): comparing a parameter against an integer pins it to an
// integer (pinning evidence wins over any weak evidence); passing NIL
// then hits the registered extraction failure at the call boundary
// ("nil -> clean type error"). Harbour prints .F. for NIL = 5 instead
// (hk271) - a registered failure-mode divergence of the pinning model,
// not a silent miscompile.
procedure main()
   ? p( 5 )
   ? p( 4 )
   ? p( nil )
   return
function p( x )
   return x = 5
