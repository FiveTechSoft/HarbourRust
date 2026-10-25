// non-call #translate at statement start (probe b19)
#translate DOUBLE <x> => ? <x> * 2
function main()
    DOUBLE 21
    return nil
