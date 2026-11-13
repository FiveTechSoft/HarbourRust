// DO name WITH arg, ... is command sugar for the bare-call statement
// (hk245): arguments evaluate (41+1 -> 42), the call runs for effect,
// and the callee's parameters keep their inferred types no matter
// which one the body uses first (63k partial-pin fix).
function greet( msg, num )
   if msg == "hi"
      ? "hello"
   else
      ? msg
   endif
   ? num + 1
   return

function main()
   do greet with "hi", 41 + 1
   do greet with "bye", 7
   return
