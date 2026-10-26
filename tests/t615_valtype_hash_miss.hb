// t615: ValType over a MISSING hash casilla is Harbour's BASE/1132-family
// error condition (hk209: the dialog hangs headless) - the registered
// clean bound-error exit 1, never a silent "U" read.
function main()
    local h := { "a" => 1 }
    ? valtype( h["zzz"] )
return nil
