// empty #command result deletes the statement (probe b40); empty
// #translate result is legal too (b44); zero-parameter function-like
// #define expands only in call form (b42).
#command NOOP <x> =>
#translate ZAP(<x>) =>
#define PI2() 6
function main()
    NOOP 99
    ? PI2()
    return nil
