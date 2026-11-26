# ValType integer arithmetic frontier

Original MIT. Increment on c31fb25. Admit structurally measured +,-,* trees whose checked result is I64, evaluate fully once, then return N. Existing F64 path unchanged. Calls keep scoped string-copy checking. Division, modulus, power, sequence, inline assignment, indexes and logical expressions not added.

Four five-mode cases give20 exact triples against Harbour: integer operators, ordered user-call effects, owned string arguments reused afterward, and mixed F64. Exception5 exact (explicit TRY oracle adapter), strict-zero4.

KNOWN RUNTIME LIMIT, NOT PARITY: boundary.prg overflows I64; Harbour promotes and prints N N N rc0, compiler runtime returns rc1 with integer-overflow numeric-promotion limit. All five modes retain this failure. No global numeric promotion added. Fixture retained, excluded from exact count. No full manifest/performance/FullLLVM claim.
