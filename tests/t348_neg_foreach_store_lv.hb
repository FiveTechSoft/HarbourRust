// storing the loop variable into a collection would escape the borrowed pointer - named error.
function main()
    local h := {"a" => 1}
    local k := hb_HKeys(h)
    local c := ""
    local b := {}
    for each c in k
        AAdd(b, c)
    next
return nil
