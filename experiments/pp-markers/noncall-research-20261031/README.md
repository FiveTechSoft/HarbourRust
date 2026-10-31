# Captured non-call translations: research only

Own probes,Harbour behavioral oracle,no production change.72initialobservations
(not144;the original temporary filename was wrong)and22expressionboundaries.
Identifier adjacency in result templates already works at statement start:
JOIN Test New => Test_New or TestNew. The missing phase is inline captured
non-call translation matching,not a general token concatenation operation.

Two identifier markers have a small prefix boundary:consume exactly two
identifiers,leave function-call/index/operator suffix intact,skip quoted text.
One identifier plus a plain expression is different:New(1,2)+7 stays inside
the capture;two adjacent words stop the capture;commas/endparentheses stop it.
An expression ending with JOIN may consume that keyword instead of recursively
matching it. This needs an expression grammar contract,not greedy rest-of-line.

Next bounded candidate could admit isolated non-call translations with only
identifier markers first. Plain tail used by real MTHNAME remains separate
until its expression boundaries are correct. No code enabled,no full gates,
no original/header/runtime/ABI/main or speed/byte claim.
