// non-call #translate with literal words and two captures (probe b20)
#translate ADD <x> AND <y> => ? <x> + <y>
function main()
    ADD 3 AND 4
    return nil
