/* Own MIT Linux snapshot adapter. Included after hrdbf_file_linux.c in unity.
 * Both snapshots are immutable and independently owned. No live file mapping. */
#include "hrntx.h"
typedef struct {
 hrntx_index index;unsigned char *bytes,*work;size_t size,work_size;
} hrntx_file;
static hrdbf_error hrntx_file_close(hrntx_file*f){
 hrdbf_error e=HRDBF_OK;hrntx_close(&f->index);
 if(f->bytes){if(syscall3(11,(long)f->bytes,f->size,0)<0)e=HRDBF_IO;else{f->bytes=0;f->size=0;}}
 if(f->work){if(syscall3(11,(long)f->work,f->work_size,0)<0)e=HRDBF_IO;else{f->work=0;f->work_size=0;}}
 return e;
}
static hrdbf_error hrntx_file_open(hrntx_file*f,const char*path,const hrdbf_area*d){
 long fd,n,r;size_t pos=0,cap,np,nr;unsigned char extra;hrdbf_error err=hrntx_file_close(f);
 if(err)return err;
 fd=open_ro(path);if(fd<0)return HRDBF_IO;
 n=syscall3(8,fd,0,2);if(n<0){err=HRDBF_IO;goto finish;}
 if(n<2048||n>HRNTX_MAX_BYTES||n%1024){err=HRDBF_FORMAT;goto finish;}
 if(syscall3(8,fd,0,0)<0){err=HRDBF_IO;goto finish;}
 f->size=(size_t)n;f->bytes=allocate(f->size);if(!f->bytes){f->size=0;err=HRDBF_MEMORY;goto finish;}
 while(pos<f->size){r=syscall3(0,fd,(long)(f->bytes+pos),f->size-pos);if(r==-4)continue;if(r<=0){err=HRDBF_IO;goto finish;}pos+=(size_t)r;}
 do{r=syscall3(0,fd,(long)&extra,1);}while(r==-4);
 if(r!=0){err=HRDBF_IO;goto finish;}
 cap=(size_t)d->count*sizeof(hrntx_entry);np=(f->size/1024+7)/8;nr=((size_t)d->count+7)/8;
 if(cap>HRNTX_MAX_BYTES){err=HRDBF_LIMIT;goto finish;}
 f->work_size=cap+np+nr;f->work=allocate(f->work_size);if(!f->work){f->work_size=0;err=HRDBF_MEMORY;goto finish;}
 if(hrntx_open(&f->index,f->bytes,f->size,d,(hrntx_entry*)f->work,d->count,f->work+cap,np+nr))err=HRDBF_FORMAT;
finish:
 if(syscall3(3,fd,0,0)<0)err=HRDBF_IO;
 if(err){hrdbf_error e=hrntx_file_close(f);if(e)return e;}
 return err;
}
