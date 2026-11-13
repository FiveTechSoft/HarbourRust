// t605: `.T. = 1` raises BASE/1071 in Harbour (oracle hk202) - here a
// compile-time rejection, registered as a differentiated failure mode
function main()
    ? .T. = 1
return nil
