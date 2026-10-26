// t616: reading a missing hash key is the same Harbour error condition
// (hk209b, dialog hangs headless) - registered clean bound-error exit 1.
function main()
    local h := { "a" => 1 }
    ? h["zzz"]
return nil
