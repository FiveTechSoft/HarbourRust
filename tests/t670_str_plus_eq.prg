// String += (oracle hk246: s += "cd" prints abcd): desugars to
// s := s + "cd" (string +, hk215). The slot must be an OWNED string -
// a parameter here (owned at the call boundary, hk216). A
// literal-initialized local is a borrowed rodata view (Ty::Str) and
// rejecting an owned value into it is the pre-existing hk225 model,
// not a += limitation.
function app( s )
   s += "cd"
   ? s
   return

function main()
   app( "ab" )
   return
