/* Own MIT unity build for the macro evaluator, generation only. Windows
 * x86-64 and Linux x86-64 over the OS primitives the DBF unity supplies
 * (allocate/deallocate). No libc, no CRT. No C compiler needed by hbc
 * users. */
#include "hrmacro.h"
#include "hrdyn.h"

/* The unity build renames the DBF blob's allocate/deallocate to the
 * hrmacro_ names the macro runtime expects. The DBF unity supplies
 * hrdbf_os_allocate; here we forward to it (the DBF unity is included
 * BEFORE this file in the combined blob, so the symbol is available). */
extern void *hrdbf_os_allocate(unsigned long long n);
extern void hrmacro_deallocate(void *p, unsigned long long n);

static void *hrmacro_allocate(unsigned long long n){
  return hrdbf_os_allocate(n);
}
#define HRC_ALLOC_DEFINED
#include "hrmacro.c"
