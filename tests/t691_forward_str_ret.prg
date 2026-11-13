// Forward call whose return value pins a local's string type across
// inference rounds (str evidence travels backward through the fixpoint).
procedure main()
   local s := greet()
   ? s + "!"
   return
function greet()
   return "hi"
