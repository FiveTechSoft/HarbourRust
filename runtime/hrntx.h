/* Own MIT read-only NTX character-field codec. Written from format docs and
 * generated fixtures, not from Harbour implementation code. Experimental. */
#ifndef HRNTX_H
#define HRNTX_H
#include "hrdbf.h"
#define HRNTX_MAX_BYTES (64u*1024u*1024u)
typedef enum {HRNTX_OK,HRNTX_FORMAT,HRNTX_SUBSET,HRNTX_SPACE,HRNTX_MISMATCH} hrntx_error;
typedef struct {uint32_t recno,key_offset;} hrntx_entry;
typedef struct {
 const unsigned char *bytes;size_t size;
 hrntx_entry *entries;uint32_t count;
 uint16_t width,field;
} hrntx_index;
/* Caller provides at least dbf->count entries and scratch bytes equal to
 * ceil(file_size/1024/8) + ceil(dbf->count/8). All storage remains caller owned.
 * Output is empty on failure; workspace contents unspecified. */
hrntx_error hrntx_open(hrntx_index*,const unsigned char*,size_t,const hrdbf_area*,
                     hrntx_entry*,size_t,unsigned char*,size_t);
void hrntx_close(hrntx_index*);
/* Prefix semantics; a query longer than key width is truncated as in oracle.
 * Result is [0,count]; count denotes no match/end. found is always set. */
uint32_t hrntx_seek(const hrntx_index*,const unsigned char*,size_t,int,int,int*);
#endif
