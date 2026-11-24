/* Own MIT Windows snapshot ownership; index borrows DBF until index close. */
#include "hrntx.h"
typedef struct{hrntx_index index;unsigned char*bytes,*work;size_t size,work_size;void*handle;int dirty;}hrntx_file;
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
/* Structural CDX autoopen probe: 1 only when the OS reports the file (or
 * its directory) missing; any other outcome means "present", so the open
 * that follows reports its own failure. */
static int hrntx_file_missing(const char*path){
 WCHAR wide[260];HANDLE h;DWORD e;
 if(!hrdbfw_path(path,wide))return 0;
 h=CreateFileW(wide,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
 if(h==INVALID_HANDLE_VALUE){e=GetLastError();return e==2||e==3;}
 CloseHandle(h);return 0;
}
/* D7: emit a fresh image from the current table snapshot, validate it with
 * the same reader that opens the file, then adopt it as the live index.
 * The on-disk file is untouched until the close-time flush. */
static hrdbf_error hrntx_file_rebuild(hrntx_file*f,const hrdbf_area*d){
 unsigned char*img,*work2;hrntx_index fresh;size_t imgcap,entrycap,sortbytes,np,nr,got,m;
 uint16_t max;hrntx_error e;
 if(!f->index.bytes)return HRDBF_CLOSED;
 max=(uint16_t)(((const unsigned char*)f->index.bytes)[18]|(((const unsigned char*)f->index.bytes)[19]<<8));
 m=d->count?(size_t)(d->count+max-1)/max:1;
 if(m>max)return HRDBF_LIMIT; /* bounded two-level subset */
 imgcap=1024*(size_t)(m+(m>1?2:1));
 sortbytes=16*(size_t)d->count;entrycap=(size_t)d->count*sizeof(hrntx_entry);
 np=(imgcap/1024+7)/8;nr=((size_t)d->count+7)/8;
 img=allocate(imgcap);if(!img)return HRDBF_MEMORY;
 work2=allocate(sortbytes+np+nr);
 if(!work2){hrdbfw_release(img);return HRDBF_MEMORY;}
 got=hrntx_build(img,(const unsigned char*)f->index.bytes,&f->index,d,work2,sortbytes);
 if(!got){hrdbfw_release(img);hrdbfw_release(work2);return HRDBF_FORMAT;}
 fresh=(hrntx_index){0};
 e=hrntx_open(&fresh,img,got,d,(hrntx_entry*)work2,d->count,work2+entrycap,np+nr);
 if(e){hrdbfw_release(img);hrdbfw_release(work2);return HRDBF_FORMAT;}
 if(f->handle){HANDLE h=f->handle;f->handle=0;CloseHandle(h);}
 if(f->bytes)hrdbfw_release(f->bytes);
 if(f->work)hrdbfw_release(f->work);
 f->bytes=img;f->size=got;f->work=work2;f->work_size=sortbytes+np+nr;f->index=fresh;f->dirty=1;
 return HRDBF_OK;
}
/* D7: write the live image back to the index file. The snapshot's read
 * handle (share mode 0) is closed first so the exclusive write handle can
 * open; the caller flushes at dbCloseArea, then closes. */
static hrdbf_error hrntx_file_flush(hrntx_file*f,const char*path){
 WCHAR wide[260];HANDLE h;LARGE_INTEGER at;DWORD done;size_t pos=0;
 if(!f->dirty||!f->bytes||!f->size)return HRDBF_OK;
 if(!hrdbfw_path(path,wide))return HRDBF_IO;
 if(f->handle){HANDLE r=f->handle;f->handle=0;CloseHandle(r);}
 h=CreateFileW(wide,GENERIC_WRITE,0,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
 if(h==INVALID_HANDLE_VALUE)return HRDBF_IO;
 at.QuadPart=0;
 if(!SetFilePointerEx(h,at,0,FILE_BEGIN)||!SetEndOfFile(h)){CloseHandle(h);return HRDBF_IO;}
 while(pos<f->size){done=0;
  if(!WriteFile(h,f->bytes+pos,(DWORD)(f->size-pos),&done,0)||!done){CloseHandle(h);return HRDBF_IO;}
  pos+=done;}
 if(!SetEndOfFile(h)){CloseHandle(h);return HRDBF_IO;}
 if(!CloseHandle(h))return HRDBF_IO;
 f->dirty=0;
 return HRDBF_OK;
}
