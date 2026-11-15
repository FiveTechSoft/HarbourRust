/* Own MIT macro evaluator runtime (M0+M1): PRIVATE/PUBLIC memvar storage
 * and a bounded expression evaluator for the `&` operator.
 *
 * The evaluator reuses the hbc Dyn value convention:
 *   tag 0 = integer, tag 1 = NIL, tag 2/4 = borrowed/owned string,
 *   tag 3 = logical, tag 9 = literal integer.
 * A macro value carries {tag, i64 payload, char *owned_str} where
 * owned_str is only set for owned-string results (tag 4).
 *
 * Stages (issue roadmap):
 *   M0: &name resolves a memvar stored via hrc_macro_set.
 *   M1: &(expr) evaluates numbers, strings, + - * / and parentheses.
 *   M2: function calls (later).
 *   M3: DBF field access (later).
 *   M4: assignments (later).
 * No libc: the memvar table uses VirtualAlloc/mmap via the OS shim
 * supplied by the unity build (the same allocate() the DBF blob uses). */
#ifndef HRMACRO_H
#define HRMACRO_H
#include <stdint.h>
#include <stddef.h>

typedef struct { uint64_t tag; int64_t payload; char *owned_str; size_t owned_len; } hrc_value;
typedef enum { HRC_OK = 0, HRC_UNDEF, HRC_TYPE, HRC_SYNTAX, HRC_MEMORY, HRC_LIMIT } hrc_error;

/* Memvar storage: set/get/remove a named value. */
void hrc_macro_init(void);
void hrc_macro_free(void);
void hrc_macro_set(const char *name, size_t name_len, uint64_t tag, int64_t payload, const char *str, size_t str_len);
int  hrc_macro_get(const char *name, size_t name_len, hrc_value *out);
int  hrc_macro_exists(const char *name, size_t name_len);

/* Expression evaluator: source is the macro text (length-bounded, not
 * NUL-terminated). Returns HRC_OK and fills *out on success. */
hrc_error hrc_macro_eval(const char *src, size_t len, hrc_value *out);

/* Free an owned string result after the caller consumed it. */
void hrc_value_free(hrc_value *v);

#endif
