// ains P2 stage 1 closure (independent-review blocker on 6896c79f): an
// output statement that borrows a Dyn root's cells freezes the root to
// the last render - the static rejection fires for a direct assignment
// anywhere in the same statement (items evaluate before rendering).
procedure main()
local x
x := { 1, "canary" }
? x[2], (x := 1)
return
