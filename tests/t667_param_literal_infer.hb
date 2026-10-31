// neg: a parameter the body never uses in a type-revealing way stays
// uninferable, and the error must name THAT parameter - not mask every
// parameter with an i64 placeholder (63k partial-pin fix: before it,
// this program died with the misleading `==` named rejection).
function greet( msg, num )
   if msg == "hi"
      ? "hello"
   endif
   return

function main()
   greet( "hi", 42 )
   return
