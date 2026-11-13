// neg: printing a whole array/hash TEMPORARY (Harbour prints any
// array or hash expression empty - hk16/hk20 - but this increment
// only accepts a variable in that position; a temporary from a call
// is never silently skipped by the static suffix analysis)
function mk()
    return {"a" => 1}
function main()
? mk()
return nil
