# Float literal width syntax coverage

Original MIT. Tests-only supplement to90e0c3b9, compiler71f49aad unchanged.
15 exact stdout/stderr/rc triples across3sources x5modes: unary + (adjacent
and spaced), whitespace around token/parentheses/minus, non-boundary positive
and negative wide values and leading-zero integer parts.
15 compile-rejection checks across3sources x5modes: exponent lower/upper and
space INSIDE number. Oracle hbmk2 build rc6 on all3; compiler rc1. These are
not runtime comparisons and do not claim identical diagnostics.

Token contract from lexer: Float strings are contiguous digits.digits or
normalized0.digits. Whitespace is outside tokens; unary + is dropped by factor;
minus folds a negative string. Exponent notation and internal whitespace do
not reach float_literal_width. Its domain is lexer-normalized decimal literals,
not arbitrary numeric text supplied by a caller.

Oracle provenance: harbour/core694428e1c12f726675b19324d62167fa77d68185.
common/hbstr.c hb_str2number fPCode width branch: unsigned written integer
width >=10 is retained for decimal tokens; below10 uses HB_DBL_LENGTH.
common/expropt2.c hb_compExprReduceNegate resets double bWidth to default,
which resolves using value width. Therefore the negative rule does NOT come
from passing a leading minus into hb_str2number. The compiler's factor mirrors
this folded-literal case. This corrects/clarifies the earlier README's short
attribution. Examples include12345678901.50 and-12345678901.50, plus leading
zeros, away from only the1e10/-1e9 thresholds. No arbitrary token input support.

No code changed. Existing block capture n+1.0 rejection is generic, unchanged.
No full Linux manifest, performance, FullLLVM or fatal-unwind closure.
