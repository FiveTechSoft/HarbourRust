// command with literal marker inside: capture stops at the literal
#command SHOW <x> AND <y> => ? <x> + <y>
function main()
    SHOW 10 AND 5
    SHOW 1+2 AND 3
    return nil
