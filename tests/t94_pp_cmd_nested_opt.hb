// nested optional clauses [TO <y> [BY <z>]] (probe b18): all three uses
#command GO <x> [TO <y> [BY <z>]] => ? <x>
function main()
    GO 1
    GO 2 TO 3
    GO 4 TO 5 BY 6
    return nil
