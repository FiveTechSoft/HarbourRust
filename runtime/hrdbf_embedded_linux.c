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
#include "hrdbf_file_linux.c"

#include "hrntx.c"
#include "hrntx_file_linux.c"
#include "hrdbf_app.c"
