/* Own MIT bounded Dyn-cell ABI proposal implementation, not enabled in hbc. */
#ifndef HRVALUE_H
#define HRVALUE_H
#include "hrdbf.h"
typedef struct { uint64_t tag,payload; } hrv_cell;
enum { HRV_I64=0,HRV_NIL=1,HRV_STR_BORROW=2,HRV_LOGICAL=3,HRV_STR_OWN=4,
       HRV_DOUBLE=5,HRV_SUBARRAY=6,HRV_BLOCK=7,HRV_ARRAY=8,HRV_I64_LITERAL=9,
       HRV_BYREF=10,HRV_DATE=11,HRV_FIELD_NUMERIC=12 };
typedef enum { HRV_OK,HRV_TYPE,HRV_DECIMAL_I64,HRV_BUFFER,HRV_TAG_INVALID } hrv_error;
/* Every consumer reads kind through this accessor, never whole-tag equality.
 * Raw-tag copying/return and extracting numeric metadata are not classification. */
static inline unsigned hrv_kind(hrv_cell v){return (unsigned)(v.tag&255u);}
static inline unsigned hrv_decimals(hrv_cell v){return (unsigned)((v.tag>>8)&255u);}
static inline unsigned hrv_width(hrv_cell v){return (unsigned)((v.tag>>16)&65535u);}
hrv_cell hrv_date(uint32_t);
hrv_cell hrv_number(int64_t,unsigned,unsigned);
hrv_error hrv_validate(hrv_cell);
char hrv_valtype(hrv_cell);
hrv_error hrv_i64(hrv_cell,int64_t *);
hrv_error hrv_equal(hrv_cell,hrv_cell,int *);
hrv_error hrv_empty(hrv_cell,int *);
/* New scalar types only; returns exact field/string byte length, no NUL contract.
 * Date format is mm/dd/yy matching current default Date render, blank='  /  /  '. */
hrv_error hrv_render(hrv_cell,unsigned char *,size_t,size_t *);
const char *hrv_error_name(hrv_error);
#endif
