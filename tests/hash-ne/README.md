# Harbour # not-equal spelling, own MIT

Source-driven increment: intact upstream tests/overload.prg contains a #
comparison. The lexer now maps this single-character spelling to the same
Tok::Ne as != and <>. No codegen, ownership, precedence or operator-overload
runtime change. Preprocessor # directives and quoted/bracket strings retain
their own processing. A # in a #translate replacement is a distinct Harbour
preprocessor construct, not an ordinary expression; initial fixture exposing
that difference failed in Harbour and was corrected, not counted as a pass.

Four sources,20exact triples in5Linux modes. Covers numeric/string/logical/NIL/
date/decimal comparisons,SET EXACT default string behavior,arithmetic/logical
precedence,IF,macro definitions and ordinary source following directives.

No original admission or closure: overload advances from character # atline24
to object-index assignment atline33. Object overload implementation remains
outside scope. Census1041/63,only overload diagnostic changes. Compiler for
this gate is opt0,not an optimized performance build.
