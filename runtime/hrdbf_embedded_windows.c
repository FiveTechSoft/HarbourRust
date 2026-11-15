/* Own MIT unity build, generation only. No C compiler is needed by hbc users.
 * Prefix even internal C names to avoid collisions in a single generated .s.
 * Header is included before macros so field names are never renamed. */
#include "hrdbf_file.h"
#include "hrvalue.h"
#define u16 hrdbf_decode_u16
#define u32 hrdbf_decode_u32
#define blank hrdbf_bytes_blank
#define number hrdbf_parse_numeric
/* function-only date rename is performed in the decoder source to avoid
 * rewriting the hrdbf_value.date field identifier through a macro. */
#define syscall3 hrdbf_os_syscall3
#define open_ro hrdbf_os_open_ro
#define allocate hrdbf_os_allocate
#include "hrdbf.c"
#include "hrvalue.c"
#include "hrdbf_file_windows.c"

#include "hrntx.c"
#include "hrcdx.c"
#include "hrntx_file_windows.c"
#define hrdbf_app_close hrdbfw_app_close
#define hrdbf_app_open hrdbfw_app_open
#define hrdbf_app_top hrdbfw_app_top
#define hrdbf_app_bottom hrdbfw_app_bottom
#define hrdbf_app_skip hrdbfw_app_skip
#define hrdbf_app_order_add hrdbfw_app_order_add
#define hrdbf_app_order_clear hrdbfw_app_order_clear
#define hrdbf_app_found hrdbfw_app_found
#define hrdbf_app_seek hrdbfw_app_seek
#define hrdbf_app_recno hrdbfw_app_recno
#define hrdbf_app_lastrec hrdbfw_app_lastrec
#define hrdbf_app_bof hrdbfw_app_bof
#define hrdbf_app_eof hrdbfw_app_eof
#define hrdbf_app_deleted hrdbfw_app_deleted
#define hrdbf_app_get hrdbfw_app_get
#define hrdbf_app_render hrdbfw_app_render
#define hrdbf_app_integer hrdbfw_app_integer
#define hrdbf_app_equal hrdbfw_app_equal
#define hrdbf_app_compare hrdbfw_app_compare
#define hrdbf_app_empty hrdbfw_app_empty
#define hrdbf_app_unsupported hrdbfw_app_unsupported
#include "hrdbf_app.c"
