/* Own MIT Windows snapshot ownership; index borrows DBF until index close. */
#include "hrntx.h"
typedef struct{hrntx_index index;unsigned char*bytes,*work;size_t size,work_size;void*handle;}hrntx_file;
static hrdbf_error hrntx_file_close(hrntx_file*f){
 hrdbf_error e=HRDBF_OK;hrntx_close(&f->index);
 if(f->handle){HANDLE h=f->handle;f->handle=0;if(!CloseHandle(h))e=HRDBF_IO;}
 if(f->bytes){if(!hrdbfw_release(f->bytes))e=HRDBF_IO;else{f->bytes=0;f->size=0;}}
 if(f->work){if(!hrdbfw_release(f->work))e=HRDBF_IO;else{f->work=0;f->work_size=0;}}
 return e;
}
static hrdbf_error hrntx_file_open(hrntx_file*f,const char*path,const hrdbf_area*d,unsigned cdx){
 size_t cap,np,nr;hrdbf_error e=hrntx_file_close(f);if(e)return e;
 e=hrdbfw_snapshot(path,&f->bytes,&f->size,&f->handle,2048,cdx?512:1024,0);if(e)goto done;
 cap=(size_t)d->count*sizeof(hrntx_entry);np=(f->size/(cdx?512:1024)+7)/8;nr=((size_t)d->count+7)/8;
 if(cap>HRNTX_MAX_BYTES){e=HRDBF_LIMIT;goto done;}
 f->work_size=cap+np+nr;f->work=allocate(f->work_size);if(!f->work){e=HRDBF_MEMORY;goto done;}
 {hrntx_error x=(cdx?hrcdx_open:hrntx_open)(&f->index,f->bytes,f->size,d,(hrntx_entry*)f->work,d->count,f->work+cap,np+nr);if(x)e=x==HRNTX_KEYWIDTH?HRDBF_TYPE:HRDBF_FORMAT;}
done:if(e){hrdbf_error c=hrntx_file_close(f);if(c)return c;}return e;
}
