/* HarbourRust own MIT dBASE III read-only codec prototype. No Harbour code. */
#ifndef HRDBF_H
#define HRDBF_H
#include <stddef.h>
#include <stdint.h>
/* 2046 descriptors fill the 16-bit header length (32 + 2046*32 + 1 bytes);
 * real Harbour 3.2 creates and opens 2046 fields and refuses 2047
 * (measured). */
#define HRDBF_MAX_FIELDS 2046
/* All byte slices borrow the input buffer. The caller keeps it alive and
 * immutable until close. No allocation, file I/O, locale or libc dependency. */
typedef enum { HRDBF_OK,HRDBF_FORMAT,HRDBF_VERSION,HRDBF_TYPE,HRDBF_LIMIT,
               HRDBF_DATA,HRDBF_CLOSED,HRDBF_IO,HRDBF_MEMORY } hrdbf_error;
typedef struct { unsigned char name[11],type,width,decimals; uint16_t offset; } hrdbf_field;
typedef struct {
 const unsigned char *bytes; size_t size;
 uint32_t count; uint64_t recno;
 uint16_t header,record,nfields;
 unsigned char bof,eof,open;
 hrdbf_field fields[HRDBF_MAX_FIELDS];
 /* D1.1: exact rejection reason, filled by hrdbf_open on failure. Empty on
  * success. Diagnostic only; never part of the accepted-format contract. */
 char diag[160];
} hrdbf_area;
typedef struct {
 unsigned char type,width,decimals; /* U (NIL) for invalid field ordinal */
 const unsigned char *text; /* C: exact width including trailing spaces */
 int64_t scaled; /* N: exact signed coefficient, divide by 10^decimals */
 uint32_t date; /* D: YYYYMMDD, 0 for blank */
 unsigned char logical;
} hrdbf_value;
hrdbf_error hrdbf_open(hrdbf_area *,const unsigned char *,size_t);
void hrdbf_close(hrdbf_area *);
hrdbf_error hrdbf_top(hrdbf_area *);
hrdbf_error hrdbf_skip(hrdbf_area *,int64_t);
hrdbf_error hrdbf_get(const hrdbf_area *,unsigned,hrdbf_value *);
hrdbf_error hrdbf_deleted(const hrdbf_area *,unsigned char *);
#endif
