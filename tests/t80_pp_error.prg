// neg: #error aborts the compile with its message
#define BROKEN
#ifdef BROKEN
#error custom failure text
#endif
function main()
    return nil
