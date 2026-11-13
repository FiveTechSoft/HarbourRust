// t497 (neg): `==` on codeblock variables is REJECTED - Harbour's
// identity is per EVALUATION (hk131/hk136/hk137: x==x .T.; distinct
// literals .F.; the same literal evaluated twice is ALSO .F.) while
// our slot holds a per-literal static pointer, which would answer
// .T. where Harbour says .F. Truthful rejection, not compatibility.
function main()
    local x := {|n| n + 1}
    local y := {|n| n + 1}
    if x == y
        ? 1
    endif
return nil
