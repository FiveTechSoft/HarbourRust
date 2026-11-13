// A string literal argument pins the parameter (multiarg literal
// evidence): Harbour retypes parameters per call; the old "parameters
// are integers" rejection is superseded by real evidence.
function id(x)
    return x

function main()
    ? id("hola")
    return nil
