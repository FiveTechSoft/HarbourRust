// user-defined command translating to our own syntax (single capture)
#command SHOW <x> => ? <x>
function main()
    SHOW 6
    show 7
    return nil
