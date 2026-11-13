// undeclared loop variable: Harbour errors BASE/1003 (oracle hk19).
function main()
    local a := {}
    for each z in a
        ? z
    next
return nil
