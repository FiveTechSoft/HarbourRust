// pos (63s, flipped from neg): a logical argument to a print-only (Dyn)
// parameter is tagged 3 at the call boundary - admission boundary, not new
// storage (hbc_print_dyn already prints tag 3, the epilogue frees only
// tag 4). Exact-case oracle hk264: prints .T., exit 0.
procedure main()
   showit( .t. )
   return
function showit( x )
   ? x
   return
