/* Own MIT Windows x86-64 private snapshots. Handles remain exclusive
 * until close, measured against official Harbour PE shared=.F. opens.
 * readonly=.F. requests GENERIC_READ|GENERIC_WRITE with share mode 0, the
 * Harbour exclusive read-write contract; no field write operations exist
 * in this increment and the snapshot is never flushed back.
 * No RDD locking or multi-file atomicity is claimed. */
#include <windows.h>
#include "hrdbf_file.h"
static int hrdbfw_device_eq(const WCHAR*p,size_t n,const char*name){size_t i;for(i=0;i<n&&name[i];i++){unsigned c=p[i];if(c>='a'&&c<='z')c-=32;if(c!=(unsigned char)name[i])return 0;}return i==n&&!name[i];}
static int hrdbfw_device(const WCHAR*p,size_t n){size_t k=0;while(k<n&&p[k]!='.')k++;while(k&&p[k-1]==' ')k--;
 if(hrdbfw_device_eq(p,k,"CON")||hrdbfw_device_eq(p,k,"PRN")||hrdbfw_device_eq(p,k,"AUX")||hrdbfw_device_eq(p,k,"NUL")||hrdbfw_device_eq(p,k,"CONIN$")||hrdbfw_device_eq(p,k,"CONOUT$")||hrdbfw_device_eq(p,k,"CLOCK$"))return 1;
 return k==4&&p[3]>='0'&&p[3]<='9'&&(hrdbfw_device_eq(p,3,"COM")||hrdbfw_device_eq(p,3,"LPT"));
}
static int hrdbfw_path(const char*p,WCHAR*w){
 size_t i=0,start=0,n,j;unsigned char c;
 if(!p[0]||(p[0]=='\\'&&p[1]=='\\')||(p[0]=='/'&&p[1]=='/'))return 0;
 while((c=(unsigned char)p[i])!=0){if(c>127||i>=259||c<32||c=='*'||c=='?'||c=='"'||c=='<'||c=='>'||c=='|'||(c==':'&&(i!=1||!((p[0]>='A'&&p[0]<='Z')||(p[0]>='a'&&p[0]<='z')))))return 0;w[i]=c=='/'?'\\':c;i++;}w[i]=0;
 if(!i)return 0;
 for(j=0;j<=i;j++)if(j==i||w[j]=='\\'){
  n=j-start;if(n){
   if((w[j-1]==' '||w[j-1]=='.')&&!(n==1&&w[start]=='.')&&!(n==2&&w[start]=='.'&&w[start+1]=='.'))return 0;
   if(hrdbfw_device(w+start,n))return 0;
  }start=j+1;
 }
 /* Reject drive-relative X:foo, rooted-without-drive and namespace paths. */
 if(w[0]=='\\'||(i>1&&w[1]==':'&&(i<3||w[2]!='\\')))return 0;
 return 1;
}
static void* allocate(size_t n){return VirtualAlloc(0,n,MEM_RESERVE|MEM_COMMIT,PAGE_READWRITE);}
static int hrdbfw_release(void*p){return VirtualFree(p,0,MEM_RELEASE)!=0;}
/* D1.1 diagnostics: OS-layer rejection reasons with the raw Win32 error.
 * TU-static sink: hrdbfw_snapshot is shared with the NTX/CDX layer, which
 * keeps its own error surface; only hrdbf_file_open copies the text out.
 * Pointer-walking loops with ivopts disabled: gcc -O2 otherwise emits
 * negated-symbol base addressing the internal assembler cannot read. */
static char fsink[160];static unsigned fsink_len;
static __attribute__((optimize("no-tree-loop-ivcanon,no-ivopts"))) void fset(const char *s){char *d=fsink;while(d<fsink+159&&*s){*d=*s;d++;s++;}*d=0;fsink_len=(unsigned)(d-fsink);}
static __attribute__((optimize("no-tree-loop-ivcanon,no-ivopts"))) void fcat(const char *s){char *d=fsink+fsink_len;while(d<fsink+159&&*s){*d=*s;d++;s++;}*d=0;fsink_len=(unsigned)(d-fsink);}
static __attribute__((optimize("no-tree-loop-ivcanon,no-ivopts"))) void fdec(uint64_t v){char t[20];unsigned n=0;do{t[n]=(char)('0'+v%10);n++;v/=10;}while(v&&n<20);while(n){n--;{char c[2]={t[n],0};fcat(c);}}}
static __attribute__((optimize("no-tree-loop-ivcanon,no-ivopts"))) void werr(const char *what,DWORD code){
 fset(what);fcat(" (win32 error ");fdec(code);fcat(")");
}
static hrdbf_error hrdbfw_snapshot(const char*path,unsigned char**bytes,size_t*size,void**handle,size_t min,unsigned page,int writable){
 WCHAR wide[260];HANDLE h;LARGE_INTEGER n,after;DWORD got,e;size_t pos=0;unsigned char extra;
 if(!hrdbfw_path(path,wide)){fset("path is not a supported plain file path (reserved device name or characters)");return HRDBF_IO;}
 h=CreateFileW(wide,GENERIC_READ|(writable?GENERIC_WRITE:0),0,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
 if(h==INVALID_HANDLE_VALUE){werr("OS open failed (2=missing, 5=access denied, 32=another program has it open)",GetLastError());return HRDBF_IO;}
 *handle=h;
 if(!GetFileSizeEx(h,&n)){werr("GetFileSizeEx failed",GetLastError());return HRDBF_IO;}
 if(n.QuadPart<(LONGLONG)min){fset("file has fewer than the 33 header bytes");return HRDBF_FORMAT;}
 if(n.QuadPart>HRDBF_MAX_BYTES){fset("file size ");fdec((uint64_t)n.QuadPart);fcat(" exceeds the 64 MiB limit");return HRDBF_FORMAT;}
 if(page&&n.QuadPart%page){fset("file size is not a whole number of pages");return HRDBF_FORMAT;}
 *size=(size_t)n.QuadPart;*bytes=allocate(*size);if(!*bytes){fset("out of memory snapshotting the file");return HRDBF_MEMORY;}
 while(pos<*size){got=0;e=0;if(!ReadFile(h,*bytes+pos,(DWORD)(*size-pos),&got,0))e=GetLastError();
  if(e||!got||got>*size-pos){werr("OS read failed",e);return HRDBF_IO;}pos+=got;}
 got=0;
 if(!ReadFile(h,&extra,1,&got,0)){werr("OS read failed",GetLastError());return HRDBF_IO;}
 if(got||!GetFileSizeEx(h,&after)||after.QuadPart!=n.QuadPart){fset("file changed size while being read");return HRDBF_IO;}
 return HRDBF_OK;
}
hrdbf_error hrdbf_file_close(hrdbf_file*f){
 hrdbf_error e=HRDBF_OK;hrdbf_close(&f->area);
 if(f->handle){HANDLE h=f->handle;f->handle=0;if(!CloseHandle(h))e=HRDBF_IO;}
 if(f->owned){if(!hrdbfw_release(f->owned))e=HRDBF_IO;else{f->owned=0;f->size=0;}}
 return e;
}
hrdbf_error hrdbf_file_open(hrdbf_file*f,const char*path,int writable){
 hrdbf_error e;
 f->diag[0]=0;fsink[0]=0;
 e=hrdbf_file_close(f);if(e)return e;
 f->diag[0]=0;fsink[0]=0;fsink_len=0;
 e=hrdbfw_snapshot(path,&f->owned,&f->size,&f->handle,33,0,writable);
 if(e){char *d=f->diag;const char *q=fsink;while(d<f->diag+159&&*q){*d=*q;d++;q++;}*d=0;}
 if(!e)e=hrdbf_open(&f->area,f->owned,f->size);
 if(e){hrdbf_error c=hrdbf_file_close(f);if(c)return c;}return e;
}
