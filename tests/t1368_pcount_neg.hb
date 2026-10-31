// neg: PCount needs the caller's argument count, which the calling
// convention does not carry in this increment (hb_PValue over the
// declared parameters is the supported introspection - multiarg family).
function p(a, b)
    ? PCount()
    return nil
function main()
    p(1)
    return nil
