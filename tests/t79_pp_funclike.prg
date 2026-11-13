// function-like define: textual substitution, nesting works
#define SQ(x) x * x
function main()
    ? SQ(9)
    ? SQ(SQ(2))
    return nil
