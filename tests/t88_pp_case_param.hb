// parameter substitution is case-sensitive too (probe a07):
// #define F(x) X + 1 must NOT substitute X -> hbc rejects undefined variable
#define F(x) X + 1
function main()
    ? F(2)
    return nil
