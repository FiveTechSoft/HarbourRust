// pos: `#pragma -es<N>` (warning severity) is inert here - warnings do
// not exist in this dialect, so the switch changes no byte of output.
#pragma -es0
function main()
    ? ( 1, 2, 3 )
    return nil
