/* Own MIT file adapter. Linux/Windows x86-64 snapshot adapters. */
#ifndef HRDBF_FILE_H
#define HRDBF_FILE_H
#include "hrdbf.h"
#define HRDBF_MAX_BYTES (64u*1024u*1024u)
typedef struct { hrdbf_area area; unsigned char *owned; size_t size;
#ifdef _WIN32
 void *handle; /* retained exclusive OS handle; no RDD lock protocol */
#endif
 /* D1.1: OS-layer rejection reason (path, size, I/O). Empty on success.
  * Survives hrdbf_file_close so the caller can report after cleanup. */
 char diag[160];
} hrdbf_file;
/* No concurrent writer or snapshot-consistency guarantee. The caller supplies
 * an offline/quiescent file. Decoder never keeps a live mapping of file pages.
 * writable=0 opens read-only. writable=1 requests an OS read-write open
 * (exclusive on Windows, O_RDWR on Linux), matching Harbour's exclusive
 * shared=.F./readonly=.F. open contract: it fails on read-only storage.
 * No field write operations exist in this increment and the snapshot is
 * never flushed back, so the open mode carries no persistence semantics. */
hrdbf_error hrdbf_file_open(hrdbf_file *,const char *,int writable);
hrdbf_error hrdbf_file_close(hrdbf_file *);
#endif
