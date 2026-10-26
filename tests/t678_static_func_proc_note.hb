// STATIC FUNCTION parses as a plain function; `proc` is an alias for
// PROCEDURE; NOTE lines are comments (oracle hk249).
STATIC FUNCTION Sf()
   RETURN 41
proc main()
   note this line is ignored
   ? sf() + 1
   return
