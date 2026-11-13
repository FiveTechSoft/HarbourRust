// A parameter the body only RETURNS pins from call-site literal
// evidence (multiarg family): x pins Str from the "ab" literal. The 63r
// contract stands for calls without literal evidence.
procedure main()
   ? q( "ab" )
   return
function q( x )
   return x
