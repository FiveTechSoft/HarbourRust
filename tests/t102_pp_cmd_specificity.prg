// most specific rule wins regardless of definition order (probes b31/b31b)
#command GO <x> => ? 2
#command GO <x> TO <y> => ? 1
function main()
    GO 5
    GO 5 TO 6
    return nil
