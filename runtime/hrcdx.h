/* Own MIT CDX single-tag character reader. Public layout + binary fixtures.
 * Shares only the own NTX read-only view/seek representation, not disk layout.
 * index.bytes points to the validated DBF snapshot; entry offsets point to
 * that record's character field. DBF must outlive this view. */
#ifndef HRCDX_H
#define HRCDX_H
#include "hrntx.h"
hrntx_error hrcdx_open(hrntx_index*,const unsigned char*,size_t,const hrdbf_area*,
                     hrntx_entry*,size_t,unsigned char*,size_t);
/* D7b: emit a fresh CDX image from the table snapshot (see hrcdx.c).
 * img must hold at least (tag header page offset + 1024 + 512*(leaves+1))
 * bytes; sort is scratch needing 16 bytes per record. Returns the image
 * size in bytes, 0 on any failure or outside the bounded one-interior-
 * level subset. */
size_t hrcdx_build(unsigned char*img,const unsigned char*in,const hrntx_index*shape,
                   const hrdbf_area*d,void*sort,size_t sortbytes);
#endif
