// specificity tie: equal literal counts, the LATEST definition wins
// (probes b47/b47b/b47c).
#command LONGER <x> => ? <x> + 100
#command LONG <x> => ? <x> + 200
#command SHOR <x> => ? <x> + 300
#command SHORTER <x> => ? <x> + 400
function main()
    LONG 1
    SHOR 2
    return nil
