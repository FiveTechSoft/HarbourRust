/* Own MIT CDX single-tag character reader. Public layout + binary fixtures.
 * Shares only the own NTX read-only view/seek representation, not disk layout.
 * index.bytes points to the validated DBF snapshot; entry offsets point to
 * that record's character field. DBF must outlive this view. */
#ifndef HRCDX_H
#define HRCDX_H
#include "hrntx.h"
hrntx_error hrcdx_open(hrntx_index*,const unsigned char*,size_t,const hrdbf_area*,
                     hrntx_entry*,size_t,unsigned char*,size_t);
#endif
