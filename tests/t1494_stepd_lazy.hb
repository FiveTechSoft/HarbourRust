// ains 1b step (c)-next: independent fixture, not Harbour source
// Laziness: the DEAD arm must not evaluate (hk321). When the raw-cell
// arm is chosen, the owned arm's side effect never runs.
procedure main()
? wrap()
? hb_memcheck()
return
function wrap()
local a := {"x",9}
?? iif(hb_isnumeric(a[1]), hb_ntos(side()), a[1])
?? "|"
?? iif(hb_isnumeric(a[2]), hb_ntos(side()), a[2])
return 0
function side()
?? "DEAD"
return 9
