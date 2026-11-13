// negative: after #uncommand removes the rule, using the command is an
// error again (Harbour: E0030 syntax error; probe b32).
#command SAYX <x> => ? <x>
#uncommand SAYX <x> => ? <x>
function main()
    SAYX 1
    return nil
