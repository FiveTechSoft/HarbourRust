/* Own MIT implementation. Linux x86-64 only, no libc, no Harbour RTL.
 * A private anonymous owned byte buffer prevents later truncation SIGBUS.
 * This is not file locking: concurrent modification during read is unsupported.
 * Add HRDBF_IO and HRDBF_MEMORY error values to distinguish OS failures.
 * D2: writable opens retain the O_RDWR descriptor and write record commits
 * back immediately with pwrite64 (no fsync, Harbour DBFCDX durability). */
#include "hrdbf_file.h"
#if !defined(__linux__) || !defined(__x86_64__)
#error Linux x86-64 adapter only
#endif
#ifndef HRDBF_TEST_SEAMS
static long syscall3(long n,long a,long b,long c){long r;__asm__ volatile("syscall":"=a"(r):"0"(n),"D"(a),"S"(b),"d"(c):"rcx","r11","memory");return r;}
static long syscall4(long n,long a,long b,long c,long d){long r;register long r10 __asm__("r10")=d;__asm__ volatile("syscall":"=a"(r):"0"(n),"D"(a),"S"(b),"d"(c),"r"(r10):"rcx","r11","memory");return r;}
static long open_dbf(const char *p,int writable){long r;register long r10 __asm__("r10")=0;do{__asm__ volatile("syscall":"=a"(r):"0"(257L),"D"(-100L),"S"(p),"d"(0x80000L|(writable?2L:0L)),"r"(r10):"rcx","r11","memory");}while(r==-4);return r;}
static void *allocate(size_t n){long r;register long r10 __asm__("r10")=0x22;register long r8 __asm__("r8")=-1;register long r9 __asm__("r9")=0;__asm__ volatile("syscall":"=a"(r):"0"(9L),"D"(0L),"S"(n),"d"(3L),"r"(r10),"r"(r8),"r"(r9):"rcx","r11","memory");return r<0&&r>=-4095?0:(void*)r;}
#else
extern long hrdbf_test_syscall3(long,long,long,long);
extern long hrdbf_test_syscall4(long,long,long,long,long);
extern long hrdbf_test_open_dbf(const char *,int);
extern void *hrdbf_test_allocate(size_t);
#define syscall3 hrdbf_test_syscall3
#define syscall4 hrdbf_test_syscall4
#define open_dbf hrdbf_test_open_dbf
#define allocate hrdbf_test_allocate
#endif
hrdbf_error hrdbf_file_close(hrdbf_file *f){
 hrdbf_error e=HRDBF_OK;
 hrdbf_close(&f->area);f->writable=0;
 if(f->fd_open){long r=syscall3(3,f->fd,0,0);f->fd_open=0;f->fd=0;if(r<0)e=HRDBF_IO;}
 if(f->owned){long r=syscall3(11,(long)f->owned,f->size,0);
 /* Do not silently abandon ownership when munmap fails; caller can retry. */
 if(r<0)return HRDBF_IO;f->owned=0;f->size=0;}
 return e;
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
 f->writable=writable!=0;
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
 /* Writable opens retain the descriptor for immediate write-back (D2). */
 if(!err&&f->writable){f->fd=fd;f->fd_open=1;return HRDBF_OK;}
 /* Linux close(EINTR) is not retried: the fd may already be released. */
 if(syscall3(3,fd,0,0)<0)err=HRDBF_IO;
 if(err){hrdbf_error cleanup=hrdbf_file_close(f);if(cleanup)return cleanup;}
 return err;
}
/* D2: exact-length write-back of one record (OpenADS write_record_raw port,
 * MIT: offset = header + (recno-1)*record, short write is an error). */
hrdbf_error hrdbf_file_write_record(hrdbf_file *f,uint64_t recno){
 uint64_t off;size_t left,record;unsigned char *p;
 if(!f->writable||!f->fd_open||!f->area.open)return HRDBF_CLOSED;
 if(!recno||recno>f->area.count)return HRDBF_FORMAT;
 record=f->area.record;off=(uint64_t)f->area.header+(recno-1)*record;
 p=f->owned+off;left=record;
 while(left){
  long w=syscall4(18,f->fd,(long)p,left,(long)off);
  if(w==-4)continue;
  if(w<=0||(size_t)w>left)return HRDBF_IO;
  p+=w;off+=w;left-=(size_t)w;
 }
 return HRDBF_OK;
}
/* D2: blank-record append (OpenADS append_record_raw port, MIT): record
 * bytes, 0x1A EOF marker, header record count and UTC header date
 * (year-1900, month, day at bytes 1-3). */
hrdbf_error hrdbf_file_append(hrdbf_file *f,uint32_t *recno){
 uint64_t off,newsize,days,z,era,doe,yoe,y,doy,mp,m,d;unsigned i;
 long ts[2];unsigned char *grown,*p;hrdbf_error e;
 if(!f->writable||!f->fd_open||!f->area.open)return HRDBF_CLOSED;
 off=(uint64_t)f->area.header+(uint64_t)f->area.record*f->area.count;
 newsize=off+f->area.record+1;
 if(newsize>HRDBF_MAX_BYTES)return HRDBF_LIMIT;
 grown=allocate(newsize);if(!grown)return HRDBF_MEMORY;
 for(i=0;i<f->size;i++)grown[i]=f->owned[i];
 p=grown+off;
 for(i=0;i<f->area.record;i++)p[i]=' ';
 p[f->area.record]=26;
 /* header: UTC date (OpenADS rewrite_header_ port) and record count */
 if(syscall3(228,0,(long)ts,0)<0){e=HRDBF_IO;goto fail;}
 days=(uint64_t)(ts[0]/86400);
 z=days+719468;era=z/146097;doe=z-era*146097;
 yoe=(doe-doe/1460+doe/36524-doe/146096)/365;
 y=yoe+era*400;doy=doe-(365*yoe+yoe/4-yoe/100);
 mp=(5*doy+2)/153;d=doy-(153*mp+2)/5+1;m=mp<10?mp+3:mp-9;if(m<=2)y++;
 grown[1]=(unsigned char)(y-1900);grown[2]=(unsigned char)m;grown[3]=(unsigned char)d;
 {
  uint32_t c=f->area.count+1;
  grown[4]=(unsigned char)c;grown[5]=(unsigned char)(c>>8);
  grown[6]=(unsigned char)(c>>16);grown[7]=(unsigned char)(c>>24);
 }
 /* write-back: header bytes 1..7, then record + EOF marker */
 {
  size_t left;long w;uint64_t at;
  p=grown+1;left=7;at=1;
  while(left){w=syscall4(18,f->fd,(long)p,left,(long)at);if(w==-4)continue;if(w<=0||(size_t)w>left){e=HRDBF_IO;goto fail;}p+=w;at+=w;left-=(size_t)w;}
  p=grown+off;left=(size_t)(newsize-off);at=off;
  while(left){w=syscall4(18,f->fd,(long)p,left,(long)at);if(w==-4)continue;if(w<=0||(size_t)w>left){e=HRDBF_IO;goto fail;}p+=w;at+=w;left-=(size_t)w;}
 }
 if(syscall3(11,(long)f->owned,f->size,0)<0){e=HRDBF_IO;goto fail;}
 f->owned=grown;f->size=(size_t)newsize;
 f->area.bytes=f->owned;f->area.size=f->size;
 f->area.count++;f->area.recno=f->area.count;f->area.bof=f->area.eof=0;
 *recno=f->area.count;
 return HRDBF_OK;
fail:
 {long r=syscall3(11,(long)grown,newsize,0);(void)r;}
 return e;
}
