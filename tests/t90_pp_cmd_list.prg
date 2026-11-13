// #command list capture <x,...> (probe b02 + std.ch): the pattern captures
// the list; the result inserts it via the plain marker <x>
#command SUM3( <x,...> ) => ? sum3( <x> )
function sum3(a, b, c)
    return a + b + c
function main()
    SUM3( 1, 2, 3 )
    return nil
