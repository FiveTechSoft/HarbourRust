// A parameter under a no-op unary plus pins from call-site literal
// evidence (multiarg family): x pins I64 from the literal 1.
function echo(x)
return +x
function main()
? echo(1)
return
