/* Own MIT file adapter. Linux/Windows x86-64 snapshot adapters. */
#ifndef HRDBF_FILE_H
#define HRDBF_FILE_H
#include "hrdbf.h"
/* The whole table is snapshotted in memory: 1 GiB bounds that allocation. */
#define HRDBF_MAX_BYTES (1024u*1024u*1024u)
typedef struct { hrdbf_area area; unsigned char *owned; size_t size;
 int writable; /* readonly=.F. open: field writes and appends admitted */
#ifdef _WIN32
 void *handle; /* retained exclusive OS handle; no RDD lock protocol */
#else
 long fd; /* retained O_RDWR descriptor in writable opens (fd_open set) */
 unsigned char fd_open;
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
 * Writable opens retain the OS descriptor/handle and write field mutations
 * back immediately (one pwrite/WriteFile per record commit, no fsync,
 * matching Harbour DBFCDX durability), so peers see committed records
 * through the OS cache. */
hrdbf_error hrdbf_file_open(hrdbf_file *,const char *,int writable);
hrdbf_error hrdbf_file_close(hrdbf_file *);

/* D2 (write path; OpenADS cdx_driver.cpp write/append semantics, MIT):
 * writes the owned snapshot of record recno (1-based) back to the file at
 * header + (recno-1)*record. Exact-length write; short write or I/O failure
 * is HRDBF_IO. Rejected with HRDBF_CLOSED when the open was not writable. */
hrdbf_error hrdbf_file_write_record(hrdbf_file *,uint64_t recno);

/* D2: appends one blank record (all spaces, delete flag ' '), rewrites the
 * header record count (bytes 4-7 LE) and the UTC header date (bytes 1-3,
 * year-1900), terminates the file with 0x1A, and grows the owned snapshot.
 * On success *recno receives the new 1-based record number and the area
 * count/cursor move to it. Rejected with HRDBF_CLOSED when not writable,
 * HRDBF_LIMIT past HRDBF_MAX_BYTES, HRDBF_MEMORY on allocation failure. */
hrdbf_error hrdbf_file_append(hrdbf_file *,uint32_t *recno);

#endif
