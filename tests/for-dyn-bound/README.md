# Ordinary local Dyn TO bound

Own MIT frontier increment. START and STEP remain typed integers; STEP must
be literal. TO is an ordinary local Dyn slot, not captured/byref/static.
Existing numeric comparison preserves integers and decimals without casting
TO to integer. TO reloads at each condition; existing counter/overflow rules
remain. No general float counter, float START/STEP or dynamic STEP extension.

check.py: 13 own programs, five Linux modes, 65 fresh Harbour-exact triples
and 13 strict final allocation-zero runs. Includes negative/fractional TO,
live reassignments, nested loops, LOOP/EXIT, >2^53 integer and mixed float
comparison, retag/catch, reused NIL counter. limits.py: ten exclusions.
Val's former integer-FOR-bound negative becomes a positive here; no stale
negative is silently weakened. Val storage gate now has361rows.

Intact seconds.prg now compiles, with an additional separate clock/range
check for bounded numeric argv. Independent real clock readings are NOT
byte-exact. No fresh full original seconds output parity claim.
