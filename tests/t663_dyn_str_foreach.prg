// neg: a FOR EACH variable holds a BORROWED tag-2 casilla and cannot be
// stored into a Dyn slot (registered limitation; the same fence rejects
// passing or returning it). This keeps borrowed views out of the owned
// tag-4 machinery by construction.
function main()
   local h := {=>}
   h["beta"] := 1
   local k, saved
   for each k in hb_HKeys( h )
      saved := k
   next
   return
