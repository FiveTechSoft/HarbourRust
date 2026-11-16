/* Own MIT implementation. Linux x86-64 only, no libc, no Harbour RTL.
 * A private anonymous owned byte buffer prevents later truncation SIGBUS.
 * This is not file locking: concurrent modification during read is unsupported.
 * Add HRDBF_IO and HRDBF_MEMORY error values to distinguish OS failures. */
#include "hrdbf_file.h"
#if !defined(__linux__) || !defined(__x86_64__)
#error Linux x86-64 adapter only
#endif
#ifndef HRDBF_TEST_SEAMS
static long syscall3(long n,long a,long b,long c){long r;__asm__ volatile("syscall":"=a"(r):"0"(n),"D"(a),"S"(b),"d"(c):"rcx","r11","memory");return r;}
static long open_dbf(const char *p,int writable){long r;register long r10 __asm__("r10")=0;do{__asm__ volatile("syscall":"=a"(r):"0"(257L),"D"(-100L),"S"(p),"d"(0x80000L|(writable?2L:0L)),"r"(r10):"rcx","r11","memory");}while(r==-4);return r;}
static void *allocate(size_t n){long r;register long r10 __asm__("r10")=0x22;register long r8 __asm__("r8")=-1;register long r9 __asm__("r9")=0;__asm__ volatile("syscall":"=a"(r):"0"(9L),"D"(0L),"S"(n),"d"(3L),"r"(r10),"r"(r8),"r"(r9):"rcx","r11","memory");return r<0&&r>=-4095?0:(void*)r;}
#else
extern long hrdbf_test_syscall3(long,long,long,long);
extern long hrdbf_test_open_dbf(const char *,int);
extern void *hrdbf_test_allocate(size_t);
#define syscall3 hrdbf_test_syscall3
#define open_dbf hrdbf_test_open_dbf
#define allocate hrdbf_test_allocate
#endif
hrdbf_error hrdbf_file_close(hrdbf_file *f){
 long r=0;hrdbf_close(&f->area);
 if(f->owned)r=syscall3(11,(long)f->owned,f->size,0);
 /* Do not silently abandon ownership when munmap fails; caller can retry. */
 if(r<0)return HRDBF_IO;f->owned=0;f->size=0;return HRDBF_OK;
}
/* D1.1 diagnostics: OS-layer rejection reasons with the raw errno.
 * Pointer-walking loops with ivopts disabled: gcc -O2 otherwise emits
 * negated-symbol base addressing the internal assembler cannot read. */
static __attribute__((optimize("no-tree-loop-ivcanon,no-ivopts"))) void fset(hrdbf_file *f,const char *s){char *d=f->diag;while(d<f->diag+159&&*s){*d=*s;d++;s++;}*d=0;}
static __attribute__((optimize("no-tree-loop-ivcanon,no-ivopts"))) void fcat(hrdbf_file *f,const char *s){char *d=f->diag;while(d<f->diag+159&&*d)d++;while(d<f->diag+159&&*s){*d=*s;d++;s++;}*d=0;}
static __attribute__((optimize("no-tree-loop-ivcanon,no-ivopts"))) void fdec(hrdbf_file *f,uint64_t v){char t[20];unsigned n=0;do{t[n]=(char)('0'+v%10);n++;v/=10;}while(v&&n<20);while(n){n--;{char c[2]={t[n],0};fcat(f,c);}}}
static __attribute__((optimize("no-tree-loop-ivcanon,no-ivopts"))) void ferr(hrdbf_file *f,const char *what,long code){
 fset(f,what);fcat(f," (errno ");
 if(code<0)code=-code;fdec(f,(uint64_t)code);fcat(f,")");
}
hrdbf_error hrdbf_file_open(hrdbf_file *f,const char *path,int writable){
 long fd,n,r;size_t pos=0;unsigned char extra;hrdbf_error err=HRDBF_OK;
 /* Caller zero-initializes the file. Reopen closes its previous owned buffer. */
 f->diag[0]=0;
 err=hrdbf_file_close(f);if(err)return err;
 f->diag[0]=0;
 fd=open_dbf(path,writable);if(fd<0){ferr(f,"OS open failed (missing file, permission or sharing conflict)",fd);return HRDBF_IO;}
 n=syscall3(8,fd,0,2);if(n<0){ferr(f,"OS seek failed",n);err=HRDBF_IO;goto closefd;}
 if(n<33){fset(f,"file has fewer than the 33 header bytes");err=HRDBF_FORMAT;goto closefd;}
 if(n>HRDBF_MAX_BYTES){fset(f,"file size ");fdec(f,(uint64_t)n);fcat(f," exceeds the 64 MiB limit");err=HRDBF_LIMIT;goto closefd;}
 if(syscall3(8,fd,0,0)<0){fset(f,"OS seek failed");err=HRDBF_IO;goto closefd;}
 f->size=(size_t)n;f->owned=allocate(f->size);if(!f->owned){f->size=0;fset(f,"out of memory snapshotting the file");err=HRDBF_MEMORY;goto closefd;}
 while(pos<f->size){r=syscall3(0,fd,(long)(f->owned+pos),f->size-pos);if(r==-4)continue;if(r<=0){ferr(f,"OS read failed",r);err=HRDBF_IO;goto closefd;}pos+=(size_t)r;}
 do{r=syscall3(0,fd,(long)&extra,1);}while(r==-4);
 if(r!=0){fset(f,"file changed size while being read");err=HRDBF_IO;goto closefd;}
 err=hrdbf_open(&f->area,f->owned,f->size);
closefd:
 /* Linux close(EINTR) is not retried: the fd may already be released. */
 if(syscall3(3,fd,0,0)<0)err=HRDBF_IO;
 if(err){hrdbf_error cleanup=hrdbf_file_close(f);if(cleanup)return cleanup;}
 return err;
}
