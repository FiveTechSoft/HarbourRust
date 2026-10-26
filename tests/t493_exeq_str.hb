// t493: string `==` is the EXACT comparison (oracle hk124): "a"=="a"
// .T., "a"=="a " .F., "a "=="a" .F. - unlike `=`, which follows the
// right-length prefix rule. Literal and variable forms; balance 0.
function main()
    local u := "a"
    local v := "a "
    if "a" == "a"
        ? 1
    else
        ? 0
    endif
    if "a" == "a "
        ? 1
    else
        ? 0
    endif
    if "a " == "a"
        ? 1
    else
        ? 0
    endif
    if u == v
        ? 1
    else
        ? 0
    endif
    if u == "a"
        ? 1
    else
        ? 0
    endif
    ? hb_memcheck()
return nil
