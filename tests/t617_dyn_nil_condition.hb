// t617: a NIL casilla in condition position is Harbour's error condition
// (hk210: IF NIL hangs on the dialog) - the registered clean exit 1 via
// hbc_dyn_to_log.
function main()
    local a := {}
    aadd( a, nil )
    if a[1]
        ? 1
    endif
return nil
