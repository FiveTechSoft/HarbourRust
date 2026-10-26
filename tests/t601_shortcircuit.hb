// t601: .AND./.OR. short-circuit, measured by call effects (oracle hk203
// shape; the by-reference counter of hk203 is out of subset, so the probe
// prints instead)
function bump_t()
    ? "evalT"
    return .T.
function bump_f()
    ? "evalF"
    return .F.
function main()
    if .F. .AND. bump_t()
        ? "rama1a"
    endif
    if .T. .OR. bump_t()
        ? "rama1b"
    endif
    if .T. .AND. bump_t()
        ? "rama2"
    endif
    if .F. .OR. bump_f()
        ? "rama3"
    endif
return nil
