# ValType of float variables

Original MIT. Checker now admits ValType over F64 variables; codegen classifies
F64 variables as N. No load/store, metadata or ownership change. Only Var
shape: literals and direct function-call expressions still reject. No new
side-effect evaluation rule.20 exact triples4sources x5modes cover module
STATIC,local STATIC,LOCAL,parameter,mutation,large positive/negative values.
40 Bool regression triples,2 scope limits,strict-zero3 Bool/persistent cleanup
controls (not float-specific),GTSTD88,Rust118.618 historical negatives and1041
census differential byte-identical to base. Census65 admissions. Historical
negative admissions/debts remain, not618 fresh rejection passes. No full Linux
manifest/performance/FullLLVM. Original initexit/fatal divergence remain OPEN.

Before input module ValType(n) rejected cleanly (rc1) in old compiler; retained.
No failed implementation build or own runtime comparison. Wide regression
float155 not repeated in this delta, only Bool40. Independent not in primary.
