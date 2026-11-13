// <(x)> match marker: source must be a parenthesized expression (b14/b16)
#command P <(x)> => ? <x>
function main()
    P ( 1 + 2 )
    return nil
