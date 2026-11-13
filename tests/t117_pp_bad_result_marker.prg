// negative: a result marker absent from the pattern is a define-time
// error (Harbour: E0008, probe b46).
#command BADRES <x> => ? <y>
function main()
    BADRES 1
    return nil
