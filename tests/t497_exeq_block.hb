// t497: `==` on two codeblock VARIABLES is identity (oracle hk131:
// x==x .T., x==y .F. for distinct literals with the same body).
function main()
    local x := {|n| n + 1}
    local y := {|n| n + 1}
    if x == x
        ? 1
    else
        ? 0
    endif
    if x == y
        ? 0
    else
        ? 0
    endif
    if y == y
        ? 1
    else
        ? 0
    endif
return nil
