// Call-site literal evidence pins a parameter the body never uses in a
// type-revealing way (multiarg family): num pins from the literal 42.
// The 63k partial-pin contract stands: a genuinely uninferable parameter
// is still named by the pin error (no literal at any call site).
function greet( msg, num )
   if msg == "hi"
      ? "hello"
   endif
   return

function main()
   greet( "hi", 42 )
   return
