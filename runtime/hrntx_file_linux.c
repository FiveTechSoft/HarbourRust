/* Own MIT Linux snapshot adapter. Included after hrdbf_file_linux.c in unity.
 * Both snapshots are immutable and independently owned. No live file mapping. */
#include "hrntx.h"
typedef struct {
 hrntx_index index;unsigned char *bytes,*work;size_t size,work_size;int dirty,cdx;
} hrntx_file;
static hrdbf_error hrntx_file_close(hrntx_file*f){
 hrdbf_error e=HRDBF_OK;hrntx_close(&f->index);
 if(f->bytes){if(syscall3(11,(long)f->bytes,f->size,0)<0)e=HRDBF_IO;else{f->bytes=0;f->size=0;}}
 if(f->work){if(syscall3(11,(long)f->work,f->work_size,0)<0)e=HRDBF_IO;else{f->work=0;f->work_size=0;}}
 return e;
}
static hrdbf_error hrntx_file_open(hrntx_file*f,const char*path,const hrdbf_area*d,unsigned cdx){
 long fd,n,r;size_t pos=0,cap,np,nr;unsigned char extra;hrdbf_error err=hrntx_file_close(f);
 if(err)return err;
 f->cdx=(int)cdx;fd=open_dbf(path,0);if(fd<0)return HRDBF_IO;
 n=syscall3(8,fd,0,2);if(n<0){err=HRDBF_IO;goto finish;}
 if(n<2048||n>HRNTX_MAX_BYTES||n%(cdx?512:1024)){err=HRDBF_FORMAT;goto finish;}
 if(syscall3(8,fd,0,0)<0){err=HRDBF_IO;goto finish;}
 f->size=(size_t)n;f->bytes=allocate(f->size);if(!f->bytes){f->size=0;err=HRDBF_MEMORY;goto finish;}
 while(pos<f->size){r=syscall3(0,fd,(long)(f->bytes+pos),f->size-pos);if(r==-4)continue;if(r<=0){err=HRDBF_IO;goto finish;}pos+=(size_t)r;}
 do{r=syscall3(0,fd,(long)&extra,1);}while(r==-4);
 if(r!=0){err=HRDBF_IO;goto finish;}
 cap=(size_t)d->count*sizeof(hrntx_entry);np=(f->size/(cdx?512:1024)+7)/8;nr=((size_t)d->count+7)/8;
 if(cap>HRNTX_MAX_BYTES){err=HRDBF_LIMIT;goto finish;}
 f->work_size=cap+np+nr;f->work=allocate(f->work_size);if(!f->work){f->work_size=0;err=HRDBF_MEMORY;goto finish;}
 {hrntx_error e=(cdx?hrcdx_open:hrntx_open)(&f->index,f->bytes,f->size,d,(hrntx_entry*)f->work,d->count,f->work+cap,np+nr);if(e)err=e==HRNTX_KEYWIDTH?HRDBF_TYPE:HRDBF_FORMAT;}
finish:
 if(syscall3(3,fd,0,0)<0)err=HRDBF_IO;
 if(err){hrdbf_error e=hrntx_file_close(f);if(e)return e;}
 return err;
}
/* Structural CDX autoopen probe: 1 only for ENOENT/ENOTDIR; any other
 * outcome means "present", so the open that follows reports its failure. */
static int hrntx_file_missing(const char*path){
 long fd=open_dbf(path,0);
 if(fd==-2||fd==-20)return 1;
 if(fd>=0)syscall3(3,fd,0,0);
 return 0;
}
/* D7: emit a fresh image from the current table snapshot, validate it with
 * the same reader that opens the file, then adopt it as the live index.
 * The on-disk file is untouched until the close-time flush. */
static hrdbf_error hrntx_file_rebuild(hrntx_file*f,const hrdbf_area*d){
 unsigned char*img,*work2;hrntx_index fresh;size_t imgcap,entrycap,sortbytes,np,nr,got,m,head;
 uint16_t max;hrntx_error e;
 if(!f->index.bytes)return HRDBF_CLOSED;
 sortbytes=16*(size_t)d->count;entrycap=(size_t)d->count*sizeof(hrntx_entry);
 if(f->cdx){
  /* D7b: same rebuild contract over the CDX codec; index.bytes aliases the
   * TABLE for CDX, so the image source is f->bytes. */
  {const unsigned char*in=(const unsigned char*)f->bytes;uint32_t dirp;
   unsigned char key[255];size_t end=512;uint32_t rec;cxleaf l;hrntx_error ce;
   if(f->size<2048||f->size%512)return HRDBF_FORMAT;
   dirp=(uint32_t)in[0]|((uint32_t)in[1]<<8)|((uint32_t)in[2]<<16)|((uint32_t)in[3]<<24);
   if(dirp<1024||dirp%512||dirp>f->size-512)return HRDBF_FORMAT;
   ce=cxleaf_header(in+dirp,10,&l);if(ce)return HRDBF_FORMAT;
   ce=cxkey(in+dirp,&l,0,10,key,&end,&rec);if(ce)return HRDBF_FORMAT;
   head=rec;
   if(head<1024||head%512||head>f->size-1024)return HRDBF_FORMAT;
  }
  imgcap=head+1024+512*(1+(size_t)(512-12)/((size_t)f->index.width+8)+1);
  np=(imgcap/512+7)/8;nr=((size_t)d->count+7)/8;
  img=allocate(imgcap);if(!img)return HRDBF_MEMORY;
  work2=allocate(sortbytes+np+nr);
  if(!work2){syscall3(11,(long)img,imgcap,0);return HRDBF_MEMORY;}
  got=hrcdx_build(img,(const unsigned char*)f->bytes,&f->index,d,work2,sortbytes);
  if(!got){syscall3(11,(long)img,imgcap,0);syscall3(11,(long)work2,sortbytes+np+nr,0);return HRDBF_FORMAT;}
  fresh=(hrntx_index){0};
  e=hrcdx_open(&fresh,img,got,d,(hrntx_entry*)work2,d->count,work2+entrycap,np+nr);
  if(e){syscall3(11,(long)img,imgcap,0);syscall3(11,(long)work2,sortbytes+np+nr,0);return HRDBF_FORMAT;}
  if(f->bytes)syscall3(11,(long)f->bytes,f->size,0);
  if(f->work)syscall3(11,(long)f->work,f->work_size,0);
  f->bytes=img;f->size=got;f->work=work2;f->work_size=sortbytes+np+nr;f->index=fresh;f->dirty=1;
  return HRDBF_OK;
 }
 max=(uint16_t)(((const unsigned char*)f->index.bytes)[18]|(((const unsigned char*)f->index.bytes)[19]<<8));
 m=d->count?(size_t)(d->count+max-1)/max:1;
 if(m>max)return HRDBF_LIMIT; /* bounded two-level subset */
 imgcap=1024*(size_t)(m+(m>1?2:1));
 np=(imgcap/1024+7)/8;nr=((size_t)d->count+7)/8;
 img=allocate(imgcap);if(!img)return HRDBF_MEMORY;
 work2=allocate(sortbytes+np+nr);
 if(!work2){syscall3(11,(long)img,imgcap,0);return HRDBF_MEMORY;}
 got=hrntx_build(img,(const unsigned char*)f->index.bytes,&f->index,d,work2,sortbytes);
 if(!got){syscall3(11,(long)img,imgcap,0);syscall3(11,(long)work2,entrycap+np+nr,0);return HRDBF_FORMAT;}
 fresh=(hrntx_index){0};
 e=hrntx_open(&fresh,img,got,d,(hrntx_entry*)work2,d->count,work2+entrycap,np+nr);
 if(e){syscall3(11,(long)img,imgcap,0);syscall3(11,(long)work2,entrycap+np+nr,0);return HRDBF_FORMAT;}
 if(f->bytes)syscall3(11,(long)f->bytes,f->size,0);
 if(f->work)syscall3(11,(long)f->work,f->work_size,0);
 f->bytes=img;f->size=got;f->work=work2;f->work_size=sortbytes+np+nr;f->index=fresh;f->dirty=1;
 return HRDBF_OK;
}
/* D7: write the live image back to the index file (open writable,
 * truncate to the new size, pwrite, close). The caller flushes at
 * dbCloseArea, then closes. */
static hrdbf_error hrntx_file_flush(hrntx_file*f,const char*path){
 long fd,r;size_t pos=0;
 if(!f->dirty||!f->bytes||!f->size)return HRDBF_OK;
 fd=open_dbf(path,1);if(fd<0)return HRDBF_IO;
 r=syscall4(77L,fd,0,(long)f->size,0); /* ftruncate to the image size */
 if(r<0){syscall3(3,fd,0,0);return HRDBF_IO;}
 while(pos<f->size){r=syscall4(18L,fd,(long)(f->bytes+pos),(long)(f->size-pos),(long)pos);
  if(r==-4)continue;
  if(r<=0){syscall3(3,fd,0,0);return HRDBF_IO;}
  pos+=(size_t)r;}
 if(syscall3(3,fd,0,0)<0)return HRDBF_IO;
 f->dirty=0;
 return HRDBF_OK;
}
