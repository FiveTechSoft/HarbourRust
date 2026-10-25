// neg: macro names are case-sensitive (Harbour behaviour, probe a05):
// `#define MiXeD` does not expand a use of `mixed`, so hbc rejects the
// undefined variable at compile time (Harbour fails later, at runtime).
#define MiXeD 5
function main()
    ? mixed
    return nil
