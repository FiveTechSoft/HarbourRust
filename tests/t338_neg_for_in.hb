// `for x in a` without EACH is Harbour's E0030 (oracle hk17): named error.
function main()
    local a := {}
    local x := 0
    for x in a
        ? x
    next
return nil
