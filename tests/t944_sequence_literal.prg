// A parameter inside a comma sequence pins from call-site literal
// evidence (multiarg family): x pins I64 from the literal 1.
function only(x)
return (1,x)
function main()
? only(1)
return
