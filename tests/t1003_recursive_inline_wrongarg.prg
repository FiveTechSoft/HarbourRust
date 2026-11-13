// neg: mixed int/string arguments make the parameter Dyn (Harbour
// retypes per call; t1363 family), and the recursive inline-iif return
// then stacks covered limits: mixed iif arms plus recursive inline
// return. The rejection is named; Harbour itself dies at runtime on
// "bad" < 1.
function f(n)
return IIF(n<1,1,f("bad"))
function main()
? f(3)
return nil
