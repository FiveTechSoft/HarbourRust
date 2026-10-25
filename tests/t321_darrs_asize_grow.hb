// Reading a GROWN (NIL) casilla in a string context: Harbour yields NIL
// (its typing is dynamic: s would BECOME NIL); the static owned string
// cannot, so this is the registered clean failure mode - exit 1 with a
// named message. Printing the same casilla prints NIL (t325).
function main()
    local h := {"one" => 1}
    local k := hb_HKeys(h)
    ASize(k, 3)
    local s := k[2]
return nil
