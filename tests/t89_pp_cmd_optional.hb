// #command optional clause [TO <y>] (probe b01): absent or present, <x> same
#command GO <x> [TO <y>] => ? <x>
function main()
    GO 1
    GO 2 TO 3
    return nil
