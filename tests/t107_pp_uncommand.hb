// #uncommand / #untranslate (probes b37a-f): exact match (pattern tokens +
// identical result text) removes ONE instance; a mismatched result or an
// unknown rule is silent.
#command SAYN <x> => ? <x>
#translate DUP(<x>) => (<x> + <x>)
#translate TRIP(<x>) => (<x> + <x> + <x>)
#translate TRIP(<x>) => (<x> + <x> + <x>)
#untranslate TRIP(<x>) => (<x> + <x> + <x>)
#untranslate NOPE(<x>) => (<x>)
function main()
    SAYN 1
    ? DUP(21)
    ? TRIP(2)
    #uncommand SAYN <x> => ? <x>
    #untranslate DUP(<x>) => WRONG
    ? DUP(3)
    return nil
