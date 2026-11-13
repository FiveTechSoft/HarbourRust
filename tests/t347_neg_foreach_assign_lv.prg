// copying the loop variable to another local would escape the borrowed pointer past the iteration - named error.
function main()
    local h := {"a" => 1}
    local k := hb_HKeys(h)
    local c := ""
    local y := NIL
    for each c in k
        y := c
    next
return nil
