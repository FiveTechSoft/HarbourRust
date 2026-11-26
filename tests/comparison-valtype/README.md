# ValType measured comparisons

Original MIT. Increment on3d41f4cd. Cmp of structurally measured arithmetic leaves/trees, variables, literals and calls is checked once and evaluated once before returning L. No AND/OR/NOT, sequence, inline assignment or indexes added. Numeric-overflow limit remains inherited.

New20 exact triples across five modes: numeric comparators, ordered user-call effects, owned string returns with caller reuse, default string comparators. Exception5 exact via explicit TRY-to-SEQUENCE oracle adapter. Strictzero3 plus stdout exact. First fixture SET EXACT OFF/ON rejected by existing SET limit, retained in evidence; default-only string fixture exact. No SET EXACT support claimed. No full manifest/perf/FullLLVM/native Windows.
