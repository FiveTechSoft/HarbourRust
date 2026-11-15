/* Developer harness: real Windows APIs plus fail/short-read injection.
 * This compiles official Windows code paths, not a Linux syscall emulation. */
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <setjmp.h>
static long handles,allocs;static int fail_open,fail_size,fail_alloc,fail_alloc_after,fail_read,short_read,zero_read,grow,fail_close,fail_free;
static jmp_buf trap;static int trapped;
static HANDLE test_create(LPCWSTR p,DWORD a,DWORD s,LPSECURITY_ATTRIBUTES q,DWORD d,DWORD f,HANDLE t){HANDLE h;if(fail_open){fail_open=0;return INVALID_HANDLE_VALUE;}h=CreateFileW(p,a,s,q,d,f,t);if(h!=INVALID_HANDLE_VALUE)handles++;return h;}
static BOOL test_size(HANDLE h,PLARGE_INTEGER n){if(fail_size){fail_size=0;return FALSE;}return GetFileSizeEx(h,n);}
static LPVOID test_alloc(LPVOID p,SIZE_T n,DWORD a,DWORD b){LPVOID v;if(fail_alloc_after&&!--fail_alloc_after)return 0;if(fail_alloc){fail_alloc=0;return 0;}v=VirtualAlloc(p,n,a,b);if(v)allocs++;return v;}
static BOOL test_free(LPVOID p,SIZE_T n,DWORD a){BOOL ok;if(fail_free){fail_free=0;return FALSE;}ok=VirtualFree(p,n,a);if(ok)allocs--;return ok;}
static BOOL test_close(HANDLE h){BOOL ok;if(fail_close){fail_close=0;return FALSE;}ok=CloseHandle(h);if(ok)handles--;return ok;}
static BOOL test_read(HANDLE h,LPVOID p,DWORD n,LPDWORD got,LPOVERLAPPED o){if(fail_read){fail_read=0;return FALSE;}if(zero_read){zero_read=0;*got=0;return TRUE;}if(grow&&n==1){grow=0;*(char*)p=0;*got=1;return TRUE;}if(short_read&&n>7)n=7;return ReadFile(h,p,n,got,o);}
static void test_exit(UINT n){trapped=(int)n;longjmp(trap,1);}
#define CreateFileW test_create
#define GetFileSizeEx test_size
#define VirtualAlloc test_alloc
#define VirtualFree test_free
#define CloseHandle test_close
#define ReadFile test_read
#define ExitProcess test_exit
#include "../../runtime/hrdbf_embedded_windows.c"
#define CHECK(x) do{if(!(x)){fprintf(stderr,"FAIL line%d h=%ld a=%ld\n",__LINE__,handles,allocs);return 1;}}while(0)
static void *copy_bytes(const void*p,size_t n){void*q=malloc(n);if(q)memcpy(q,p,n);return q;}
int main(void){
 hrdbf_file f={0};hrntx_file ix={0};int i;hrdbf_error e;hrv_cell c;
 {const char*bad[]={"CON.dbf","CON .dbf","CONIN$","CONOUT$","CLOCK$","LPT1.txt","\\\\server\\data.dbf","C:data.dbf","1:\\data.dbf","root.","d\303\241ta.dbf"};size_t k;WCHAR wide[260];
  for(k=0;k<sizeof(bad)/sizeof(bad[0]);k++){fail_open=1;CHECK(hrdbf_file_open(&f,bad[k])!=0);CHECK(fail_open==1&&handles==0&&allocs==0);fail_open=0;}
  CHECK(hrdbfw_path("COM123.dbf",wide));
 }
 for(i=0;i<200;i++){
  CHECK(hrdbf_file_open(&f,"cdxprobe.dbf")==0);CHECK(handles==1&&allocs==1);
  CHECK(hrntx_file_open(&ix,"names.cdx",&f.area,1)==0);CHECK(handles==2&&allocs==3);
  if(i==0){HANDLE h;h=CreateFileW(L"cdxprobe.dbf",GENERIC_READ,7,0,OPEN_EXISTING,0,0);CHECK(h==INVALID_HANDLE_VALUE&&GetLastError()==32);h=CreateFileW(L"names.cdx",GENERIC_WRITE,7,0,OPEN_EXISTING,0,0);CHECK(h==INVALID_HANDLE_VALUE&&GetLastError()==32);}

  CHECK(hrntx_file_close(&ix)==0);
  if(i==0){HANDLE h=CreateFileW(L"names.cdx",GENERIC_READ,7,0,OPEN_EXISTING,0,0);CHECK(h!=INVALID_HANDLE_VALUE);CHECK(CloseHandle(h));}
  CHECK(hrdbf_file_close(&f)==0);CHECK(handles==0&&allocs==0);
 }
 short_read=1;CHECK(hrdbf_file_open(&f,"cdxprobe.dbf")==0);short_read=0;CHECK(hrdbf_file_close(&f)==0);
 for(i=0;i<6;i++){
  if(i==0)fail_open=1;if(i==1)fail_size=1;if(i==2)fail_alloc=1;if(i==3)fail_read=1;if(i==4)zero_read=1;if(i==5)grow=1;
  CHECK(hrdbf_file_open(&f,"cdxprobe.dbf")!=0);CHECK(!f.area.open&&handles==0&&allocs==0);
 }
 CHECK(hrdbf_file_open(&f,"cdxprobe.dbf")==0);
 for(i=0;i<6;i++){
  if(i==0)fail_open=1;if(i==1)fail_size=1;if(i==2)fail_alloc=1;if(i==3)fail_read=1;if(i==4)zero_read=1;if(i==5)grow=1;
  CHECK(hrntx_file_open(&ix,"names.cdx",&f.area,1)!=0);CHECK(!ix.index.bytes&&handles==1&&allocs==1);
 }
 fail_alloc_after=2;CHECK(hrntx_file_open(&ix,"names.cdx",&f.area,1)!=0);CHECK(handles==1&&allocs==1);
 CHECK(hrdbf_file_close(&f)==0);
 /* VirtualFree failure keeps ownership for one explicit caller retry. */
 CHECK(hrdbf_file_open(&f,"cdxprobe.dbf")==0);fail_free=1;CHECK(hrdbf_file_close(&f)!=0&&f.owned&&allocs==1);CHECK(hrdbf_file_close(&f)==0&&allocs==0);
 /* CloseHandle failure is terminal/unknown. Not retried, counted as unreleased.
  * Simulate the OS actually closed it but returned failure to avoid test leak. */
 CHECK(hrdbf_file_open(&f,"cdxprobe.dbf")==0);{HANDLE h=f.handle;fail_close=1;e=hrdbf_file_close(&f);CHECK(e!=0&&f.handle==0&&handles==1);CHECK(CloseHandle(h));}CHECK(handles==0&&allocs==0);
 /* App string result is independent of the DBF snapshot after close. */
 hrdbfw_app_open((const unsigned char*)"cdxprobe.dbf",12,1,1);c=hrdbfw_app_get(1,copy_bytes);CHECK(c.payload!=0);hrdbfw_app_close();CHECK(((char*)c.payload)[0]=='K');free((void*)c.payload);CHECK(handles==0&&allocs==0);
 trapped=0;if(!setjmp(trap)){hrdbfw_app_open((const unsigned char*)"cdxprobe.dbf",12,1,1);hrdbfw_app_order_add((const unsigned char*)"missing.cdx",11);CHECK(0);}CHECK(trapped==1&&handles==0&&allocs==0);
 trapped=0;if(!setjmp(trap)){hrdbfw_app_open((const unsigned char*)"missing.dbf",11,1,1);CHECK(0);}CHECK(trapped==1&&handles==0&&allocs==0);
 printf("PASS resources200 cycles, short reads,13 injected open failures,free/close failure accounting,string lifetime,fatal cleanup; handles=%ld snapshots=%ld\n",handles,allocs);return 0;
}
