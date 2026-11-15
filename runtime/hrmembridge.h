/* Internal ownership bridge. Native C ABI callbacks per target.
 * No frontend/evaluator enablement. No raw storage value escapes. */
#ifndef HRMEMBRIDGE_H
#define HRMEMBRIDGE_H
#include "hrmemvar.h"
typedef hrmv_status (*hrmb_string_fn)(void*,const unsigned char*,size_t,hrv_cell*);
typedef hrmv_status (*hrmb_float_fn)(void*,uint64_t,uint64_t,hrv_cell*);
typedef struct {
 hrmv_context storage;
 void *compiler_user;
 hrmb_string_fn string_copy;
 hrmb_float_fn float_new;
} hrmb_context;
hrmv_status hrmb_init(hrmb_context*,hrmv_alloc_fn,hrmv_free_fn,void*,hrmb_string_fn,hrmb_float_fn,void*);
void hrmb_destroy(hrmb_context*);
hrmv_status hrmb_frame_enter(hrmb_context*,uint64_t*);
hrmv_status hrmb_frame_leave(hrmb_context*,uint64_t);
hrmv_status hrmb_declare(hrmb_context*,int,const char*,size_t);
/* Declare and put are separate semantic steps, NOT an atomic transaction.
 * If put fails after a new declaration, its NIL/.F. default remains.
 * Successful callbacks return compiler-owned cells; on failure callbacks
 * retain/free their own partial resources and transfer no ownership. */
hrmv_status hrmb_declare_put(hrmb_context*,int,const char*,size_t,hrv_cell);
hrmv_status hrmb_get_copy(hrmb_context*,const char*,size_t,hrv_cell*);
#endif
