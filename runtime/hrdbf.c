/* Own MIT implementation from public file-format descriptions and black-box
 * Harbour fixtures. Freestanding decoder/workarea only, not an RDD driver.
 * Snapshot, one physical-order cursor, SET DELETED OFF. No writes or locks. */
#include "hrdbf.h"
static unsigned u16(const unsigned char *p){return p[0]|((unsigned)p[1]<<8);}
static uint32_t u32(const unsigned char *p){return (uint32_t)p[0]|((uint32_t)p[1]<<8)|((uint32_t)p[2]<<16)|((uint32_t)p[3]<<24);}
void hrdbf_close(hrdbf_area *a){a->bytes=0;a->size=0;a->count=0;a->recno=0;a->nfields=0;a->open=0;a->bof=1;a->eof=1;}
/* D1.1 diagnostics: exact rejection reasons for failed opens. The buffer is
 * owned by the area and survives hrdbf_close so callers can report after
 * cleanup. hrdbf_open clears it on entry. */
static __attribute__((optimize("no-tree-loop-ivcanon,no-ivopts"))) void dset(hrdbf_area *a,const char *s){char *d=a->diag;while(d<a->diag+159&&*s){*d=*s;d++;s++;}*d=0;}
static __attribute__((optimize("no-tree-loop-ivcanon,no-ivopts"))) void dcat(hrdbf_area *a,const char *s){char *d=a->diag;while(d<a->diag+159&&*d)d++;while(d<a->diag+159&&*s){*d=*s;d++;s++;}*d=0;}
static __attribute__((optimize("no-tree-loop-ivcanon,no-ivopts"))) void ddec(hrdbf_area *a,uint64_t v){char t[20];unsigned n=0;do{t[n]=(char)('0'+v%10);n++;v/=10;}while(v&&n<20);while(n){n--;char c[2]={t[n],0};dcat(a,c);}}
static __attribute__((optimize("no-tree-loop-ivcanon,no-ivopts"))) void dhex(hrdbf_area *a,unsigned v){const char *h="0123456789ABCDEF";char c[2];c[1]=0;c[0]=h[(v>>4)&15];dcat(a,c);c[0]=h[v&15];dcat(a,c);}
static __attribute__((optimize("no-tree-loop-ivcanon,no-ivopts"))) void dname(hrdbf_area *a,const unsigned char *n){unsigned i;for(i=0;i<11&&n[i];i++){char c[2];c[0]=(char)n[i];c[1]=0;if(n[i]<32||n[i]>126)c[0]='?';dcat(a,c);}}
static int blank(const unsigned char *p,unsigned n){unsigned i;for(i=0;i<n;i++)if(p[i]!=' ')return 0;return 1;}
static hrdbf_error number(const unsigned char *p,const hrdbf_field *f,int64_t *out){
 unsigned b=0,e=f->width,i,frac=0,seen=0,point=0;int neg=0;uint64_t v=0,limit;
 while(b<e&&p[b]==' ')b++;while(e>b&&p[e-1]==' ')e--;
 if(b==e){*out=0;return HRDBF_OK;}
 if(p[b]=='-'||p[b]=='+'){neg=p[b]=='-';b++;}
 limit=neg?(uint64_t)INT64_MAX+1:(uint64_t)INT64_MAX;
 for(i=b;i<e;i++){
  unsigned c=p[i];if(c=='.'&&!point){point=1;continue;}
  if(c<'0'||c>'9')return HRDBF_DATA;
  if(v>(limit-(c-'0'))/10)return HRDBF_LIMIT;
  v=v*10+c-'0';seen=1;if(point)frac++;
 }
 if(!seen||frac>f->decimals)return HRDBF_DATA;
 while(frac++<f->decimals){if(v>limit/10)return HRDBF_LIMIT;v*=10;}
 *out=neg?(v==(uint64_t)INT64_MAX+1?INT64_MIN:-(int64_t)v):(int64_t)v;
 return HRDBF_OK;
}
static hrdbf_error hrdbf_parse_date(const unsigned char *p,uint32_t *out){
 static const unsigned char days[]={31,28,31,30,31,30,31,31,30,31,30,31};
 unsigned i,y,m,d,n=0,max;
 if(blank(p,8)){*out=0;return HRDBF_OK;}
 for(i=0;i<8;i++){if(p[i]<'0'||p[i]>'9')return HRDBF_DATA;n=n*10+p[i]-'0';}
 y=n/10000;m=n/100%100;d=n%100;
 if(!y||m<1||m>12||!d)return HRDBF_DATA;
 max=days[m-1];if(m==2&&y%4==0&&(y%100!=0||y%400==0))max++;
 if(d>max)return HRDBF_DATA;*out=n;return HRDBF_OK;
}
hrdbf_error hrdbf_top(hrdbf_area *a){if(!a->open)return HRDBF_CLOSED;a->recno=1;a->bof=a->eof=a->count==0;return HRDBF_OK;}
hrdbf_error hrdbf_skip(hrdbf_area *a,int64_t n){
 uint64_t k;if(!a->open)return HRDBF_CLOSED;
 if(!n)return HRDBF_OK;
 a->bof=0;
 if(n>0){k=(uint64_t)n;if(k>(uint64_t)a->count+1-a->recno)a->recno=(uint64_t)a->count+1;else a->recno+=k;}
 else{k=(uint64_t)(-(n+1))+1;if(k>=a->recno){a->recno=1;a->bof=1;}else a->recno-=k;}
 a->eof=!a->bof&&(a->count==0||a->recno>a->count);return HRDBF_OK;
}
hrdbf_error hrdbf_get(const hrdbf_area *a,unsigned n,hrdbf_value *v){
 const hrdbf_field *f;const unsigned char *p;unsigned c;
 v->type='U';v->width=v->decimals=v->logical=0;v->text=0;v->scaled=0;v->date=0;
 if(!a->open)return HRDBF_CLOSED;if(!n||n>a->nfields)return HRDBF_OK;
 f=&a->fields[n-1];v->type=f->type;v->width=f->width;v->decimals=f->decimals;
 if(a->recno>a->count)return HRDBF_OK; /* blank record at EOF; C text=NULL */
 p=a->bytes+a->header+(size_t)(a->recno-1)*a->record+f->offset;
 if(f->type=='C'){v->text=p;return HRDBF_OK;}
 if(f->type=='N')return number(p,f,&v->scaled);
 if(f->type=='D')return hrdbf_parse_date(p,&v->date);
 c=*p;if(c=='T'||c=='t'||c=='Y'||c=='y')v->logical=1;
 else if(c!='F'&&c!='f'&&c!='N'&&c!='n'&&c!='?'&&c!=' ')return HRDBF_DATA;
 return HRDBF_OK;
}
hrdbf_error hrdbf_deleted(const hrdbf_area *a,unsigned char *v){if(!a->open)return HRDBF_CLOSED;*v=a->recno<=a->count&&a->bytes[a->header+(size_t)(a->recno-1)*a->record]=='*';return HRDBF_OK;}
/* The candidate area holds HRDBF_MAX_FIELDS descriptors (about 32 KiB):
 * static storage, so no frame needs a stack probe (__chkstk is not
 * linked). File scope with the hrdbf_ prefix: the blob generators keep
 * that symbol name as is. */
static hrdbf_area hrdbf_open_tmp;
/* No loop distribution: the descriptor copy below must not become a
 * memcpy call (the blobs link no libc). */
__attribute__((optimize("no-tree-loop-distribute-patterns")))
hrdbf_error hrdbf_open(hrdbf_area *a,const unsigned char *b,size_t size){
 hrdbf_area *const t=&hrdbf_open_tmp;
 size_t i,end,pos=32;unsigned off=1,j,k,terminated=0;hrdbf_value val;hrdbf_error err;
 a->diag[0]=0;t->diag[0]=0;
 hrdbf_close(a);hrdbf_close(t);
 a->diag[0]=0;
 if(size<33){dset(a,"file has fewer than the 33 header bytes");return HRDBF_FORMAT;}
 if(b[0]!=3){dset(a,"version byte 0x");dhex(a,b[0]);dcat(a," is not 0x03 (dBASE III table without memo; 0x83/0xF5 carry a memo file)");return HRDBF_VERSION;}
 /* D1.1: header flag bytes 14/15/28/29 are accepted and preserved verbatim
  * (Antonio's real M_CLIE.DBF carries byte 28 = 0x01, the production-index
  * flag for its M_CLIE.cdx). Read-only acceptance: no byte of these flags is
  * ever written back, and no structural index or codepage conversion is
  * derived from them. Bytes are preserved as read; no conversion promise. */
 t->header=u16(b+8);t->record=u16(b+10);t->count=u32(b+4);
 if(t->header<33||t->header>size||!t->record){
  dset(a,"implausible header length ");ddec(a,t->header);dcat(a," or record length ");ddec(a,t->record);dcat(a," for file size ");ddec(a,size);return HRDBF_FORMAT;}
 while(pos<t->header){
  hrdbf_field *f;
  if(b[pos]==13){terminated=1;pos++;break;}
  if(t->header-pos<32){dset(a,"field descriptor ");ddec(a,t->nfields+1);dcat(a," truncated before end of header");return HRDBF_FORMAT;}
  if(t->nfields==HRDBF_MAX_FIELDS){dset(a,"more than 2046 field descriptors");return HRDBF_LIMIT;}
  f=&t->fields[t->nfields++];
  for(j=0;j<11;j++)f->name[j]=b[pos+j];
  if(!f->name[0]){dset(a,"field descriptor ");ddec(a,t->nfields);dcat(a," has an empty name");return HRDBF_FORMAT;}
  for(j=0;j+1<t->nfields;j++){for(k=0;k<11&&t->fields[j].name[k]==f->name[k];k++);if(k==11){dset(a,"duplicate field name '");dname(a,f->name);dcat(a,"'");return HRDBF_FORMAT;}}
  f->type=b[pos+11];f->width=b[pos+16];f->decimals=b[pos+17];f->offset=(uint16_t)off;
  if(!f->width){dset(a,"field '");dname(a,f->name);dcat(a,"' has zero width");return HRDBF_FORMAT;}
  if(f->type=='C'){if(f->decimals){dset(a,"C field '");dname(a,f->name);dcat(a,"' declares decimals");return HRDBF_TYPE;}}
  else if(f->type=='N'){if(f->decimals>17||f->decimals>=f->width){dset(a,"N field '");dname(a,f->name);dcat(a,"' width ");ddec(a,f->width);dcat(a," / decimals ");ddec(a,f->decimals);dcat(a," outside supported range");return HRDBF_LIMIT;}}
  else if(f->type=='L'){if(f->width!=1||f->decimals){dset(a,"L field '");dname(a,f->name);dcat(a,"' width must be 1 with no decimals");return HRDBF_FORMAT;}}
  else if(f->type=='D'){if(f->width!=8||f->decimals){dset(a,"D field '");dname(a,f->name);dcat(a,"' width must be 8 with no decimals");return HRDBF_FORMAT;}}
  else{dset(a,"field '");dname(a,f->name);dcat(a,"' has unsupported type '");{char c[2]={(char)f->type,0};if(f->type<32||f->type>126)c[0]='?';dcat(a,c);}dcat(a,"' (only C/N/D/L, no memo)");return HRDBF_TYPE;}
  off+=f->width;if(off>65535){dset(a,"field widths exceed the 65535 record limit");return HRDBF_LIMIT;}pos+=32;
 }
 if(!terminated){dset(a,"field descriptors not terminated by 0x0D");return HRDBF_FORMAT;}
 if(!t->nfields){dset(a,"table declares no fields");return HRDBF_FORMAT;}
 if(off!=t->record){dset(a,"field widths plus delete flag sum to ");ddec(a,off);dcat(a," but header record length is ");ddec(a,t->record);return HRDBF_FORMAT;}
 while(pos<t->header)if(b[pos++]){dset(a,"nonzero byte between field descriptors and header end");return HRDBF_FORMAT;}
 if(t->count>(size-t->header)/t->record){dset(a,"header record count ");ddec(a,t->count);dcat(a," exceeds the ");ddec(a,(size-t->header)/t->record);dcat(a," records physically present");return HRDBF_FORMAT;}
 end=t->header+(size_t)t->count*t->record;
 if(end!=size&&(size-end!=1||b[end]!=26)){dset(a,"unexpected trailing bytes after the last record (no 0x1A terminator)");return HRDBF_FORMAT;}
 t->bytes=b;t->size=size;t->open=1;hrdbf_top(t);
 /* Fail closed before exposing a cursor on malformed records. */
 for(i=0;i<t->count;i++){
  unsigned char mark=b[t->header+i*t->record];
  if(mark!=' '&&mark!='*'){dset(a,"record ");ddec(a,i+1);dcat(a," has delete flag 0x");dhex(a,mark);dcat(a," (expected space or '*')");return HRDBF_DATA;}
  t->recno=i+1;for(j=1;j<=t->nfields;j++){err=hrdbf_get(t,j,&val);if(err){
   dset(a,"record ");ddec(a,i+1);dcat(a," field '");dname(a,t->fields[j-1].name);
   dcat(a,err==HRDBF_LIMIT?"' numeric content overflows int64":"' content is not valid for its type");
   if(t->fields[j-1].type=='L')dcat(a," (logical byte must be T/F/Y/N/?/space)");
   if(mark=='*')dcat(a," inside a deleted record");
   return err;}}
 }
 hrdbf_top(t);
 /* Member copy: a whole-struct assignment of about 32 KiB is a memcpy. */
 a->bytes=t->bytes;a->size=t->size;a->count=t->count;a->recno=t->recno;
 a->header=t->header;a->record=t->record;a->nfields=t->nfields;
 a->bof=t->bof;a->eof=t->eof;
 for(j=0;j<t->nfields;j++){
  for(k=0;k<11;k++)a->fields[j].name[k]=t->fields[j].name[k];
  a->fields[j].type=t->fields[j].type;a->fields[j].width=t->fields[j].width;
  a->fields[j].decimals=t->fields[j].decimals;a->fields[j].offset=t->fields[j].offset;
 }
 a->diag[0]=0;a->open=1;return HRDBF_OK;
}
