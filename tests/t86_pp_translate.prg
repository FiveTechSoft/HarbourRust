// #translate with paren-attached pattern, usable inside expressions.
// (Result text must be syntax hbc supports: no parens in the template.)
#translate DOUBLE( <x> ) => <x> * 2
function main()
    ? DOUBLE(21)
    ? DOUBLE(1) + DOUBLE(2)
    return nil
