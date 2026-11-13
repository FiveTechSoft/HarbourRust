// <(x)> in the result re-inserts the capture parenthesized (b17)
#command P <(x)> => ? <(x)> * 2
function main()
    P ( 1 + 2 )
    return nil
