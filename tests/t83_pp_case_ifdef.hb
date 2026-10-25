// #ifdef name matching is case-sensitive too (probe a06): LOWER != lower.
#define lower 5
function main()
#ifdef LOWER
    ? 1
#else
    ? 2
#endif
    return nil
