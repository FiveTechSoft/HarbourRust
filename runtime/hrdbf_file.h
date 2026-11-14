/* Own MIT read-only file adapter. Linux x86-64 prototype only. */
#ifndef HRDBF_FILE_H
#define HRDBF_FILE_H
#include "hrdbf.h"
#define HRDBF_MAX_BYTES (64u*1024u*1024u)
typedef struct { hrdbf_area area; unsigned char *owned; size_t size; } hrdbf_file;
/* No concurrent writer or snapshot-consistency guarantee. The caller supplies
 * an offline/quiescent file. Decoder never keeps a live mapping of file pages. */
hrdbf_error hrdbf_file_open(hrdbf_file *,const char *);
hrdbf_error hrdbf_file_close(hrdbf_file *);
#endif
