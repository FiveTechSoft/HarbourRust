// negative: angle-form #include <file> is NOT searched next to the source
// file without -I (Harbour: F0029, probe b38); t110_inc_angle_only.ch sits
// beside this test and must not be found.
#include <t110_inc_angle_only.ch>
function main()
    ? 1
    return nil
