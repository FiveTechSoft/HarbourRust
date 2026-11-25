/* Own MIT experimental CDX codec. No external implementation source used. */
#include "hrcdx.h"
static uint16_t cx16(const unsigned char*p){return (uint16_t)(p[0]|((uint16_t)p[1]<<8));}
static uint32_t cx32(const unsigned char*p){return (uint32_t)p[0]|((uint32_t)p[1]<<8)|((uint32_t)p[2]<<16)|((uint32_t)p[3]<<24);}
static uint32_t cxbe(const unsigned char*p){return ((uint32_t)p[0]<<24)|((uint32_t)p[1]<<16)|((uint32_t)p[2]<<8)|p[3];}
static int cxcmp(const unsigned char*a,const unsigned char*b,size_t n){size_t i;for(i=0;i<n;i++)if(a[i]!=b[i])return a[i]<b[i]?-1:1;return 0;}
static unsigned char cxupper(unsigned char c){return c>='a'&&c<='z'?c-32:c;}
static int cxmark(unsigned char*b,uint32_t n){unsigned char m=(unsigned char)(1u<<(n%8));if(b[n/8]&m)return 0;b[n/8]|=m;return 1;}
static int cxpage(uint32_t p,size_t size){return p>=1024&&p%512==0&&p<=size-512;}
typedef struct {uint16_t n,free;unsigned rb,db,tb,bytes;uint32_t mask;unsigned dm,tm;} cxleaf;
static hrntx_error cxleaf_header(const unsigned char*p,unsigned width,cxleaf*l){
 l->n=cx16(p+2);l->free=cx16(p+12);l->mask=cx32(p+14);l->dm=p[18];l->tm=p[19];l->rb=p[20];l->db=p[21];l->tb=p[22];l->bytes=p[23];
 if(!l->rb||l->rb>32||!l->db||l->db>8||!l->tb||l->tb>8||!l->bytes||l->bytes>6||l->rb+l->db+l->tb!=8*l->bytes)return HRNTX_FORMAT;
 if(l->mask!=(uint32_t)((UINT64_C(1)<<l->rb)-1)||l->dm!=((1u<<l->db)-1)||l->tm!=((1u<<l->tb)-1)||l->dm<width||l->tm<width)return HRNTX_FORMAT;
 if(l->n>(512-24)/l->bytes||l->free>488)return HRNTX_FORMAT;return HRNTX_OK;
}
static hrntx_error cxkey(const unsigned char*p,const cxleaf*l,unsigned i,unsigned width,unsigned char*key,size_t*end,uint32_t*rec){
 uint64_t v=0;unsigned j,dup,trail,n;for(j=0;j<l->bytes;j++)v|=(uint64_t)p[24+i*l->bytes+j]<<(8*j);
 *rec=(uint32_t)v&l->mask;dup=(unsigned)(v>>l->rb)&l->dm;trail=(unsigned)(v>>(l->rb+l->db))&l->tm;
 if((!i&&dup)||dup+trail>width)return HRNTX_FORMAT;n=width-dup-trail;
 if(*end<n||*end-n<24+(size_t)l->n*l->bytes)return HRNTX_FORMAT;*end-=n;
 for(j=0;j<n;j++)key[dup+j]=p[*end+j];for(j=width-trail;j<width;j++)key[j]=' ';return HRNTX_OK;
}
typedef struct {
 const unsigned char*b;size_t size;const hrdbf_area*d;hrntx_index*x;
 unsigned char*pages,*records;uint32_t used;
 int leaf_depth;uint32_t prev[64],right[64];
} cxwalk;
static hrntx_error cxvisit(cxwalk*w,uint32_t page,unsigned depth){
 const unsigned char*p;unsigned flags,n,i;uint32_t left,right,rec,offset,before;unsigned char key[255];size_t end=512;hrntx_error e;cxleaf l;
 if(depth>=64||!cxpage(page,w->size)||!cxmark(w->pages,page/512))return HRNTX_FORMAT;
 p=w->b+page;flags=cx16(p);n=cx16(p+2);if(flags!=(depth?0u:1u)&&flags!=(depth?2u:3u))return HRNTX_FORMAT;
 left=cx32(p+4);right=cx32(p+8);
 if(left!=(w->prev[depth]?w->prev[depth]:UINT32_MAX)||(w->prev[depth]&&w->right[depth]!=page))return HRNTX_FORMAT;
 if(right!=UINT32_MAX&&!cxpage(right,w->size))return HRNTX_FORMAT;
 w->prev[depth]=page;w->right[depth]=right;
 if(flags&2){
  if(w->leaf_depth<0)w->leaf_depth=(int)depth;else if(w->leaf_depth!=(int)depth)return HRNTX_FORMAT;
  e=cxleaf_header(p,w->x->width,&l);if(e)return e;
  for(i=0;i<n;i++){
   e=cxkey(p,&l,i,w->x->width,key,&end,&rec);if(e)return e;
   if(!rec||rec>w->d->count||w->used>=w->d->count||!cxmark(w->records,rec-1))return HRNTX_MISMATCH;
   offset=w->d->header+(rec-1)*(uint32_t)w->d->record+w->d->fields[w->x->field].offset;
   if(cxcmp(key,w->d->bytes+offset,w->x->width))return HRNTX_MISMATCH;
   if(w->used){hrntx_entry a=w->x->entries[w->used-1];int c=cxcmp(w->d->bytes+a.key_offset,key,w->x->width);if(c>0||(c==0&&a.recno>=rec))return HRNTX_FORMAT;}
   w->x->entries[w->used].recno=rec;w->x->entries[w->used].key_offset=offset;w->used++;
  }
  if(end-(24+(size_t)n*l.bytes)!=l.free)return HRNTX_FORMAT;
 }else{
  if(!n||n>(512u-12)/(w->x->width+8))return HRNTX_FORMAT;
  for(i=0;i<n;i++){
   unsigned pos=12+i*(w->x->width+8);uint32_t child=cxbe(p+pos+w->x->width+4);before=w->used;
   e=cxvisit(w,child,depth+1);if(e)return e;
   if(w->used==before)return HRNTX_FORMAT;
   {hrntx_entry last=w->x->entries[w->used-1];if(last.recno!=cxbe(p+pos+w->x->width)||cxcmp(p+pos,w->d->bytes+last.key_offset,w->x->width))return HRNTX_FORMAT;}
  }
 }
 return HRNTX_OK;
}
static hrntx_error cxheader(const unsigned char*b,unsigned options,int directory){
 unsigned i;if(b[14]!=options||b[15]!=1||cx16(b+16)!=1024||cx16(b+18)!=512||cx16(b+502))return HRNTX_SUBSET;
 /* Admit known producer-neutral empty reserved fields, plus the observed
  * directory file marker RCHB. No casefold/codepage/collation extensions. */
 for(i=20;i<502;i++)if(b[i]&&!(directory&&i<24))return HRNTX_SUBSET;
 if(directory&&(b[20]!='R'||b[21]!='C'||b[22]!='H'||b[23]!='B'))return HRNTX_SUBSET;
 if(cx16(b+506)!=1||cx16(b+504)!=cx16(b+510)||cx16(b+508))return HRNTX_SUBSET;
 return HRNTX_OK;
}
hrntx_error hrcdx_open(hrntx_index*x,const unsigned char*b,size_t size,const hrdbf_area*d,hrntx_entry*entries,size_t cap,unsigned char*scratch,size_t scratch_size){
 uint32_t dir,header;size_t np,nr,end=512,len,i,j;unsigned field;cxleaf l;unsigned char key[255];hrntx_error e;cxwalk w;
 hrntx_close(x);
 if(!b||size<2048||size>HRNTX_MAX_BYTES||size%512||!d||!d->open)return HRNTX_FORMAT;
 e=cxheader(b,0xe0,1);if(e)return e;
 if(cx16(b+12)!=10||cx16(b+510)!=1||b[512])return HRNTX_SUBSET;
 dir=cx32(b);if(!cxpage(dir,size))return HRNTX_FORMAT;
 if(cx16(b+dir)!=3||cx16(b+dir+2)!=1)return HRNTX_SUBSET; /* exactly one tag */
 if(cx32(b+dir+4)!=UINT32_MAX||cx32(b+dir+8)!=UINT32_MAX)return HRNTX_FORMAT;
 e=cxleaf_header(b+dir,10,&l);if(e)return e;e=cxkey(b+dir,&l,0,10,key,&end,&header);if(e)return e;
 if(end-(24+l.bytes)!=l.free||!cxpage(header,size)||header>size-1024||header==dir||header+512==dir)return HRNTX_FORMAT;
 for(i=0;i<10;i++)if(key[i]!=' '&&(key[i]<'A'||key[i]>'Z')&&(key[i]<'0'||key[i]>'9')&&key[i]!='_')return HRNTX_SUBSET;
 e=cxheader(b+header,0x60,0);if(e)return e;
 len=cx16(b+header+510);if(len<2||len>256||b[header+512+len-1])return HRNTX_SUBSET;
 if(b[header+512+len])return HRNTX_SUBSET;
 for(i=0;i<len-1;i++)if(!b[header+512+i])return HRNTX_SUBSET;
 field=d->nfields;
 for(i=0;i<d->nfields;i++){
  for(j=0;j<len-1&&j<11&&d->fields[i].name[j]&&cxupper(d->fields[i].name[j])==cxupper(b[header+512+j]);j++);
  if(j==len-1&&(j==11||!d->fields[i].name[j])){field=(unsigned)i;break;}
 }
 if(field==d->nfields||d->fields[field].type!='C')return HRNTX_SUBSET;
 if(d->fields[field].width>240)return HRNTX_KEYWIDTH;
 if(d->fields[field].width!=cx16(b+header+12))return HRNTX_SUBSET;
 if(cap<d->count||(!entries&&d->count))return HRNTX_SPACE;
 np=(size/512+7)/8;nr=((size_t)d->count+7)/8;if(!scratch||scratch_size<np+nr)return HRNTX_SPACE;
 for(i=0;i<np+nr;i++)scratch[i]=0;
 cxmark(scratch,0);cxmark(scratch,1);cxmark(scratch,dir/512);cxmark(scratch,header/512);cxmark(scratch,header/512+1);
 x->bytes=d->bytes;x->size=d->size;x->entries=entries;x->count=0;x->width=d->fields[field].width;x->field=(uint16_t)field;
 w.b=b;w.size=size;w.d=d;w.x=x;w.pages=scratch;w.records=scratch+np;w.used=0;w.leaf_depth=-1;
 for(i=0;i<64;i++)w.prev[i]=w.right[i]=0;
 e=cxvisit(&w,cx32(b+header),0);if(!e&&w.used!=d->count)e=HRNTX_MISMATCH;
 for(i=0;!e&&i<64;i++)if(w.prev[i]&&w.right[i]!=UINT32_MAX)e=HRNTX_FORMAT;
 if(e){hrntx_close(x);return e;}x->count=w.used;return HRNTX_OK;
}
/* D7b: emit a fresh CDX image from the table snapshot, mirroring the
 * landed NTX builder. Ground truth from oracle-written trees (single-leaf
 * 3-record t.cdx and a 200-record two-leaf bigc.cdx, dumped 2026-11-24):
 * page flags are 3=depth-0 leaf, 2=deep leaf, 1=depth-0 interior,
 * 0=deep interior; leaves carry bitfield-packed entries (rec low bits,
 * dup, trail - all LITTLE-endian) with key bytes stored backward from the
 * page end and free == (512 - key bytes) - (24 + n*bytes) exactly; the
 * interior holds ONE entry per leaf ({key, rec, child} big-endian at
 * 12+i*(width+8)) whose (key,rec) DUPLICATE the last entry of that child
 * leaf; the root sits after the leaves. Uncompressed entries (dup=0,
 * trail=0) are legal, so the rebuild stores every key whole; the
 * bit-field allocation mirrors the oracle's exact-sum rule
 * (rb+db+tb == 8*bytes, rb padded). The directory page, tag header page
 * and key-expression page are copied verbatim; only the root pointer in
 * the header page is rewritten. Bounded subset: one interior level
 * (leaves <= (512-12)/(width+8)) and no page-reuse (the original tree
 * pages are simply dropped). sort needs 16 bytes per record. */
typedef struct {uint32_t recno;const unsigned char*key;} cxsortitem;
static int cxentry_lt(const cxsortitem*a,const cxsortitem*b,uint16_t width){
 int c=cxcmp(a->key,b->key,width);
 if(c)return c<0;
 return a->recno<b->recno;
}
static void cxput16(unsigned char*p,uint16_t v){p[0]=(unsigned char)v;p[1]=(unsigned char)(v>>8);}
static void cxput32(unsigned char*p,uint32_t v){p[0]=(unsigned char)v;p[1]=(unsigned char)(v>>8);p[2]=(unsigned char)(v>>16);p[3]=(unsigned char)(v>>24);}
static void cxputbe(unsigned char*p,uint32_t v){p[0]=(unsigned char)(v>>24);p[1]=(unsigned char)(v>>16);p[2]=(unsigned char)(v>>8);p[3]=(unsigned char)v;}
static unsigned cxbits(unsigned x){unsigned b=1;while(b<32&&((1u<<b)-1)<x)b++;return b;}
size_t hrcdx_build(unsigned char*img,const unsigned char*in,const hrntx_index*shape,
                   const hrdbf_area*d,void*sort,size_t sortbytes){
 uint16_t width=shape->width,field=shape->field;
 size_t n=d->count,m,i,j,dir,header,leafbase,root,ncap,icap;
 unsigned db,tb,rb,bytes,rbits;cxsortitem*s;
 if(!img||!in||!d->open||!width||!sort||sortbytes<16*n)return 0;
 dir=cx32(in);
 if(!cxpage(dir,d->size)||cx16(in+dir)!=3||cx16(in+dir+2)!=1)return 0;
 {cxleaf l;unsigned char key[255];size_t end=512;uint32_t rec;hrntx_error e;
  e=cxleaf_header(in+dir,10,&l);if(e)return 0;
  e=cxkey(in+dir,&l,0,10,key,&end,&rec);if(e)return 0;
  header=rec;
  if(!cxpage(header,d->size))return 0;
 }
 rbits=cxbits((unsigned)(n?n:1));
 if(rbits<16)rbits=16;
 for(bytes=3;bytes<=6;bytes++){
  db=tb=cxbits(width);rb=8*bytes-2*db;
  if(rb<=32&&rb>=rbits&&((1u<<rb)-1u)>=d->count)break;
  if(bytes==6){db=tb=8;rb=32;} /* wide tables: 32+8+8=48=6*8 */
 }
 if(rb+db+tb!=8*bytes||rb>32)return 0;
 ncap=488/((size_t)width+bytes);
 icap=(512-12)/((size_t)width+8);
 if(!ncap||!icap)return 0;
 m=n?(n+ncap-1)/ncap:1;
 if(m>icap)return 0; /* bounded one-interior-level subset */
 s=(cxsortitem*)sort;
 for(i=0;i<n;i++){
  s[i].recno=(uint32_t)(i+1);
  s[i].key=d->bytes+d->header+i*(size_t)d->record+d->fields[field].offset;
 }
 for(i=1;i<n;i++){cxsortitem e2=s[i];j=i;
  while(j&&cxentry_lt(&e2,&s[j-1],width)){s[j]=s[j-1];j--;}
  s[j]=e2;
 }
 for(i=0;i<(size_t)header+1024;i++)img[i]=in[i]; /* directory, tag header and expression pages */
 leafbase=header+1024;
 for(i=0;i<m;i++){
  unsigned char*p=img+leafbase+512*i;
  size_t a=i*ncap,b=i==m-1?n:a+ncap,k=b-a,end=512;
  for(j=0;j<512;j++)p[j]=0;
  cxput16(p,(uint16_t)(i==0&&m==1?3:2)); /* depth-0 leaf vs deep leaf */
  cxput16(p+2,(uint16_t)k);
  cxput32(p+4,i==0?UINT32_MAX:(uint32_t)(leafbase+512*(i-1)));
  cxput32(p+8,i==m-1?UINT32_MAX:(uint32_t)(leafbase+512*(i+1)));
  cxput16(p+12,(uint16_t)(end-(24+k*bytes)-k*width));
  cxput32(p+14,(uint32_t)((1ULL<<rb)-1));
  p[18]=(unsigned char)((1u<<db)-1);p[19]=(unsigned char)((1u<<tb)-1);
  p[20]=(unsigned char)rb;p[21]=(unsigned char)db;p[22]=(unsigned char)tb;p[23]=(unsigned char)bytes;
  for(j=0;j<k;j++){
   uint64_t v=(uint64_t)s[a+j].recno;unsigned q;
   for(q=0;q<bytes;q++)p[24+j*bytes+q]=(unsigned char)(v>>(8*q));
   end-=width;
   for(q=0;q<width;q++)p[end+q]=s[a+j].key[q];
  }
 }
 root=leafbase;
 if(m>1){
  unsigned char*p=img+leafbase+512*m; /* interior after the leaves */
  root=leafbase+512*m;
  for(j=0;j<512;j++)p[j]=0;
  cxput16(p,1); /* depth-0 interior */
  cxput16(p+2,(uint16_t)m);
  cxput32(p+4,UINT32_MAX);cxput32(p+8,UINT32_MAX);
  for(i=0;i<m;i++){
   size_t pos=12+i*((size_t)width+8),last=i==m-1?n:(i+1)*ncap;
   unsigned q;
   for(q=0;q<width;q++)p[pos+q]=s[last-1].key[q];
   cxputbe(p+pos+width,s[last-1].recno);
   cxputbe(p+pos+width+4,(uint32_t)(leafbase+512*i));
  }
 }
 cxput32(img+header,(uint32_t)root);
 return leafbase+512*(size_t)(m+(m>1?1:0));
}
