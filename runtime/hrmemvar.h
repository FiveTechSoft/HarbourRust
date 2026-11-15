/* Own MIT scalar MEMVAR storage. No frontend/evaluator integration.
 * Strings follow Dyn16: payload points to bytes with uint64 length at [-1].
 * get_copy returns owned tag4 strings; caller must use hrmv_value_free.
 * Inputs are borrowed for the duration of a call, never consumed. */
#ifndef HRMEMVAR_H
#define HRMEMVAR_H
#include "hrvalue.h"
#define HRMV_NAME_MAX 63u

typedef enum { HRMV_OK=0, HRMV_UNDEFINED, HRMV_TYPE_UNSUPPORTED,
 HRMV_BAD_NAME, HRMV_MEMORY, HRMV_LIMIT, HRMV_BAD_FRAME, HRMV_BAD_ARGUMENT } hrmv_status;
typedef void *(*hrmv_alloc_fn)(void *,size_t);
typedef void (*hrmv_free_fn)(void *,void *,size_t);
typedef struct {
 void *bindings,*frames,*user;
 hrmv_alloc_fn alloc; hrmv_free_fn free;
 uint64_t next_frame,current_frame;
 size_t live_bindings,live_frames;
} hrmv_context;

hrmv_status hrmv_init(hrmv_context *,hrmv_alloc_fn,hrmv_free_fn,void *);
void hrmv_destroy(hrmv_context *);
hrmv_status hrmv_frame_enter(hrmv_context *,uint64_t *);
/* Leave only the current frame. The caller unwinds frames in LIFO order. */
hrmv_status hrmv_frame_leave(hrmv_context *,uint64_t);
hrmv_status hrmv_declare_public(hrmv_context *,const char *,size_t);
hrmv_status hrmv_declare_private(hrmv_context *,const char *,size_t);
hrmv_status hrmv_get_copy(hrmv_context *,const char *,size_t,hrv_cell *);
/* Missing name creates PRIVATE in current frame. Allocation failure preserves
 * the old binding/value. No argument is consumed. */
hrmv_status hrmv_put_copy(hrmv_context *,const char *,size_t,hrv_cell);
hrmv_status hrmv_exists(hrmv_context *,const char *,size_t,int *);
/* Named RELEASE: visible PRIVATE becomes NIL (no pop); PUBLIC is removed.
 * Missing name is a successful no-op. Not RELEASE ALL/masks. */
hrmv_status hrmv_release_name(hrmv_context *,const char *,size_t);
void hrmv_value_free(hrmv_context *,hrv_cell *);
#endif
