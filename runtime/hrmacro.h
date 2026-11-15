/* Own MIT. Macro operator runtime (M1) - compiler-facing contract.
 *
 * hrmacro_eval(text, len) evaluates one constant Harbour expression and
 * returns an OWNED 16-byte Dyn cell in rax/rdx (SysV): kind 9 integer,
 * 1 NIL, 3 logical, 4 owned string (hbc_stralloc data pointer, freed by
 * hbc_freestr), 5 heap float (hbc_float_new). Errors print Harbour's
 * message to stderr and exit 1. The C body lives in hrmacro.c and is
 * compiled ahead of time to generated/hrmacro.s by
 * tests/generate_macro_asm.py; hbc supplies the hrm_* shims.
 *
 * M0 (PRIVATE/PUBLIC lookup) needs memvar storage in hbc first and is not
 * part of this runtime yet: a bare name is Harbour's BASE/1003. */
#ifndef HRMACRO_H
#define HRMACRO_H
typedef struct { unsigned long long tag, payload; } hrm_cell;
hrm_cell hrmacro_eval(const unsigned char *src, unsigned long long len);
#endif
