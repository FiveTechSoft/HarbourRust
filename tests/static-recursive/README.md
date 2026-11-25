# Recursive factory returns with a validated STATIC block seed

Own MIT. The existing self-recursion inference retry now checks a final direct
BlockLit in the already checked prefix environment. Only a successfully
validated canonical integer STATIC block seeds a Block return signature.
Self-call returns may use that checked factory signature. The full body is
rechecked against the seed; local/mixed captures and incompatible branches
still fail. Windows and macro routes remain outside this increment.
No heap environment, frame retention, ABI or runtime code changes.

25 exact triples: recursive factory depth4,0,37, multiple statics and IF
branch return. Four named rejections: local tail, mixed parameter tail,
incompatible scalar branch and Windows. Three distinct strict-zero sources
exercise recursion depth4,0,37 with final cleanup (rc99,DELTA=0).

This admits only frame-independent static-only block factories. Detached
xLocal lifetime, indirect block returns, arrays of blocks and intact
statics.prg remain unsupported. No ASort/globalRC/numeric-array division.
Black-box oracle https://github.com/harbour/core.git at
694428e1c12f726675b19324d62167fa77d68185.
