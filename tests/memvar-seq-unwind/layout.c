/* Original MIT. Guard the SysV shim's only C-layout assumption. */
#include <stddef.h>
#include "../../runtime/hrmacro.h"
typedef char bridge_at_zero[offsetof(hrmacro_context,bridge)==0?1:-1];
typedef char storage_at_zero[offsetof(hrmb_context,storage)==0?1:-1];
typedef char frame_at_48[offsetof(hrmv_context,current_frame)==48?1:-1];
int main(void){return 0;}
