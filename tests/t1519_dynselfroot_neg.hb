// ains P2 stage 1 closure (independent-review blocker on 6896c79f): the
// index of a cell read/store on a Dyn root may not mention the root
// itself - an assignment there frees the owner before the tag-8 guard
// reads it. Static rejection (the owner is statically visible).
procedure main()
local x
x := { 1, "canary" }
x[(x := 1, 1)] := 9
return
