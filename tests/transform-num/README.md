# Numeric TRANSFORM with plain templates

`Transform(n, pic)` on an integer or float first argument with a string
LITERAL picture (plain `9`/`#`/`$`/`*` digit masks, `.`, `,` and other
literal characters). runtime/hrtransform.c transcribes Harbour 3.2:
`hb_itemStrBuf` (vm/itemapi.c, modf digit extraction, 16-digit rounding
pass, sign-loss overflow, asterisk tail) plus the numeric branch of
`hb_Transform` (rtl/transfrm.c): the picture scan, the `iWidth == 0`
item defaults (long items use the pinned hbc Str field defaults), the
bAdjust strip when `iWidth - iDec == 1` and the template loop (its
`iCount` restarts at 0; the `.`/`,` slots consume a digit position).

Named rejections in this increment: `@` picture functions (`@!`, `@E`,
...), non-literal pictures, non-numeric first arguments and Dyn/NumLocal
values. Result owns its text; overflow renders the sized asterisk field.

`expected/*.windows.out` is real Harbour 3.2 output (hbmk2
-comp=mingw64 -gtcgi, native Windows 11); the Linux file is the same
bytes with LF line ends. A 45-line matrix and a 112-line sweep are
byte-identical, and the whole 77-program non-Linux battery plus the
compile-only PE manifest keep passing.
