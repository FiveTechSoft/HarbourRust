/* Own MIT. Contextual macro evaluator/compiler ownership boundary.
 * Internal SysV when generated, native C in the host harness. No recovery. */
#ifndef HRMACRO_H
#define HRMACRO_H
#include "hrmembridge.h"
typedef hrv_cell hrm_cell;
typedef void (*hrmacro_fatal_fn)(void*,const unsigned char*,size_t);
/* P1: raw backing reuse is private to this context, never a value cache. */
typedef struct {
 hrmv_alloc_fn alloc; hrmv_free_fn free; void *user;
 void *all,*bins[4]; size_t retained,live_blocks,live_bytes;
} hrmacro_raw_pool;
typedef struct {
 hrmb_context bridge;
 hrmacro_fatal_fn fatal;
 void *fatal_user;
 size_t scratch_live,lookups;
 hrmacro_raw_pool raw_pool;
} hrmacro_context;
hrmv_status hrmacro_init(hrmacro_context*,hrmv_alloc_fn,hrmv_free_fn,void*,hrmb_string_fn,hrmb_float_fn,void*,hrmacro_fatal_fn,void*);
void hrmacro_destroy(hrmacro_context*);
hrm_cell hrmacro_eval(hrmacro_context*,const unsigned char*,size_t);
void hrmacro_start(hrmacro_context*);
uint64_t hrmacro_enter(hrmacro_context*);
void hrmacro_leave(hrmacro_context*,uint64_t);
void hrmacro_declare(hrmacro_context*,int,const unsigned char*,size_t);
void hrmacro_put(hrmacro_context*,const unsigned char*,size_t,uint64_t,uint64_t);
hrm_cell hrmacro_lookup(hrmacro_context*,const unsigned char*,size_t);
uint64_t hrmacro_exists(hrmacro_context*,const unsigned char*,size_t);
void hrmacro_str_check(hrmacro_context*,uint64_t,uint64_t,int);
#endif
