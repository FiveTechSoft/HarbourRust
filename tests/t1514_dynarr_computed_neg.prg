// ains P2 stage 1 named rejection: computed literal items are NOT part of
// the stage-1 Dyn-held scalar array (only scalar literals).
procedure main()
local x, y := 3
x := { 1, y + 1 }
return
