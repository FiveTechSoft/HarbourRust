// t515: string casilla < integer casilla is Harbour's BASE/1075
// "Argument error: >" (oracle hk150 - dialog hangs headless, no
// oracle): clean named exit 1, registered failure mode.
function main()
    local h := {"a" => 1}
    local a := {}
    AAdd(a, 7)
    local k := hb_HKeys(h)
    local c := 0
    for each c in k
        if c > a[1]
            ? 1
        else
            ? 0
        endif
    next
return nil
