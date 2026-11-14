/* Own MIT. See hrntx.h. All disk reads are bounded little-endian accesses. */
#include "hrntx.h"
static uint16_t nx16(const unsigned char*p){return (uint16_t)(p[0]|((uint16_t)p[1]<<8));}
static uint32_t nx32(const unsigned char*p){return (uint32_t)p[0]|((uint32_t)p[1]<<8)|((uint32_t)p[2]<<16)|((uint32_t)p[3]<<24);}
static int nxcmp(const unsigned char*a,const unsigned char*b,size_t n){size_t i;for(i=0;i<n;i++)if(a[i]!=b[i])return a[i]<b[i]?-1:1;return 0;}
static unsigned char nxupper(unsigned char c){return c>='a'&&c<='z'?c-32:c;}
static int nxmark(unsigned char*b,uint32_t n){unsigned char m=(unsigned char)(1u<<(n%8));if(b[n/8]&m)return 0;b[n/8]|=m;return 1;}
typedef struct {
 hrntx_index *out;const hrdbf_area*dbf;
 unsigned char *pages,*records;
 uint16_t max,item;uint32_t used;int leaf_depth;
} nxwalk;
static hrntx_error nxvisit(nxwalk*w,uint32_t page,unsigned depth){
 const unsigned char*b=w->out->bytes,*p;uint16_t n,i,off,j,other;uint32_t child,rec,key;hrntx_error e;
 if(depth>63||!page||page%1024||page>w->out->size-1024||!nxmark(w->pages,page/1024))return HRNTX_FORMAT;
 p=b+page;n=nx16(p);if(n>w->max||(!n&&depth))return HRNTX_FORMAT;
 /* Offset slots cannot point into their table or overlap. Check all n+1
  * full slots, including the sentinel child slot. No in-place assumptions. */
 for(i=0;i<=n;i++){
  off=nx16(p+2+2*i);
  if(off<2+2*(w->max+1)||(size_t)off+w->item>1024)return HRNTX_FORMAT;
  for(j=0;j<i;j++){other=nx16(p+2+2*j);if(off<other+w->item&&other<off+w->item)return HRNTX_FORMAT;}
 }
 child=nx32(p+nx16(p+2));
 if(!child){if(w->leaf_depth<0)w->leaf_depth=(int)depth;else if(w->leaf_depth!=(int)depth)return HRNTX_FORMAT;}
 for(i=0;i<=n;i++){
  off=nx16(p+2+2*i);
  if((nx32(p+off)!=0)!=(child!=0))return HRNTX_FORMAT;
  if(child){e=nxvisit(w,nx32(p+off),depth+1);if(e)return e;}
  if(i==n)break;
  rec=nx32(p+off+4);key=page+off+8;
  if(!rec||rec>w->dbf->count||w->used>=w->dbf->count||!nxmark(w->records,rec-1))return HRNTX_MISMATCH;
  if(nxcmp(b+key,w->dbf->bytes+w->dbf->header+(size_t)(rec-1)*w->dbf->record+w->dbf->fields[w->out->field].offset,w->out->width))return HRNTX_MISMATCH;
  if(w->used){hrntx_entry prev=w->out->entries[w->used-1];int c=nxcmp(b+prev.key_offset,b+key,w->out->width);if(c>0||(c==0&&prev.recno>=rec))return HRNTX_FORMAT;}
  w->out->entries[w->used].recno=rec;w->out->entries[w->used].key_offset=key;w->used++;
 }
 return HRNTX_OK;
}
void hrntx_close(hrntx_index*x){x->bytes=0;x->size=0;x->entries=0;x->count=0;x->width=0;x->field=0;}
hrntx_error hrntx_open(hrntx_index*x,const unsigned char*b,size_t size,const hrdbf_area*d,hrntx_entry*entries,size_t cap,unsigned char*scratch,size_t scratch_size){
 uint16_t width,max,field;size_t i,j,len,np,nr;nxwalk w;hrntx_error e;
 hrntx_close(x);
 if(!b||size<2048||size>HRNTX_MAX_BYTES||size%1024||!d||!d->open)return HRNTX_FORMAT;
 /* Only standard ascending, nonunique, unconditional, noncustom NTX.
  * Reject every nonzero extension flag rather than assume its semantics. */
 if(nx16(b)!=6||nx16(b+16)!=0)return HRNTX_SUBSET;
 for(i=278;i<1024;i++)if((i<538||i>=550)&&b[i])return HRNTX_SUBSET;
 width=nx16(b+14);max=nx16(b+18);
 if(!width||width>255||nx16(b+12)!=width+8||!max||max>510||nx16(b+20)!=max/2||(size_t)2+2*(max+1)+(size_t)(max+1)*(width+8)>1024)return HRNTX_FORMAT;
 for(len=0;len<256&&b[22+len];len++);if(!len||len==256)return HRNTX_SUBSET;
 field=d->nfields;
 for(i=0;i<d->nfields;i++){
  for(j=0;j<len&&j<11&&d->fields[i].name[j]&&nxupper(d->fields[i].name[j])==nxupper(b[22+j]);j++);
  if(j==len&&(j==11||!d->fields[i].name[j])){field=(uint16_t)i;break;}
 }
 if(field==d->nfields||d->fields[field].type!='C'||d->fields[field].width!=width)return HRNTX_SUBSET;
 if(cap<d->count||(!entries&&d->count))return HRNTX_SPACE;
 np=(size/1024+7)/8;nr=((size_t)d->count+7)/8;
 if(!scratch||scratch_size<np+nr)return HRNTX_SPACE;
 for(i=0;i<np+nr;i++)scratch[i]=0;
 x->bytes=b;x->size=size;x->entries=entries;x->width=width;x->field=field;
 w.out=x;w.dbf=d;w.pages=scratch;w.records=scratch+np;w.max=max;w.item=width+8;w.used=0;w.leaf_depth=-1;
 e=nxvisit(&w,nx32(b+4),0);
 if(!e&&w.used!=d->count)e=HRNTX_MISMATCH;
 if(e){hrntx_close(x);return e;}x->count=w.used;return HRNTX_OK;
}
uint32_t hrntx_seek(const hrntx_index*x,const unsigned char*q,size_t n,int soft,int last,int*found){
 uint32_t lo=0,hi=x->count,first,after;int c;
 *found=0;if(n>x->width)n=x->width;
 while(lo<hi){uint32_t mid=lo+(hi-lo)/2;c=nxcmp(x->bytes+x->entries[mid].key_offset,q,n);if(c<0)lo=mid+1;else hi=mid;}
 first=lo;
 if(first<x->count&&!nxcmp(x->bytes+x->entries[first].key_offset,q,n)){
  *found=1;if(!last)return first;
  hi=x->count;while(lo<hi){uint32_t mid=lo+(hi-lo)/2;c=nxcmp(x->bytes+x->entries[mid].key_offset,q,n);if(c<=0)lo=mid+1;else hi=mid;}after=lo;return after-1;
 }
 if(!soft)return x->count;
 /* findLast reverses the miss direction in Harbour's NTX oracle. */
 if(last)return first?first-1:x->count;
 return first;
}
