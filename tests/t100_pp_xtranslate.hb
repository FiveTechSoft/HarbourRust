// #xtranslate accepted like #translate (probe b26); x- priority over a
// same-pattern #translate is NOT emulated (aliased, documented)
#xtranslate TRIPLE( <x> ) => <x> * 3
function main()
    ? TRIPLE( 14 )
    return nil
