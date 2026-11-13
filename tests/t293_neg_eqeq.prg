// t293 (repurposed in iteration 36): integer `==` between variables
// compiles and compares like `=` (oracle hk124 measured the literal
// form: 1==1 .T., 1==2 .F.; same runtime operation for variables).
function main()
    local a := 1
    local b := 1
    if a == b
        ? 1
    endif
return
