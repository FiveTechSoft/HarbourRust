/* Own MIT. Single internal-SysV translation unit, shares B1 source not copies. */
#define valid hrmv_valid
#define upper hrmv_upper
#include "hrmemvar.c"
#undef valid
#undef upper
#define valid hrmb_valid
#include "hrmembridge.c"
#undef valid
#include "hrmacro.c"
