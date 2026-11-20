# String codeblocks for AScan with captures

Extends `AScan(a, {|e[, i]| ...})` to string arrays (`DArrS`): the first
block parameter is the element as a borrowed Str pair (the cell's string
object, no copy), the optional second parameter is the 1-based position.
Remaining free names in the body resolve as READ-ONLY captures of the
enclosing function's locals: the analysis registers them per block id and
the codegen passes the owner's `%rbp` in `%r10` at the call site; the
block prologue copies each capture out of the owner frame before any
helper call. Only direct codeblock literals as AScan's second argument
enter this route; blocks stored in variables, captures assigned inside
the block, `@`-parameters and non-16-byte casillas stay named rejections.

`expected/*.windows.out` is real Harbour 3.2 output (hbmk2 -comp=mingw64
-gtcgi, native Windows 11); the Linux file is the same bytes with LF line
ends. hbc_t10 output is byte-identical, and the whole 76-program
non-Linux battery plus the compile-only PE manifest keep passing.
