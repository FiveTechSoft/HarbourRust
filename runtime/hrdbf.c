/* Own MIT implementation from public file-format descriptions and black-box
 * Harbour fixtures. Freestanding decoder/workarea only, not an RDD driver.
 * Snapshot, one physical-order cursor, SET DELETED OFF. No writes or locks. */
#include "hrdbf.h"
static unsigned u16(const unsigned char *p){return p[0]|((unsigned)p[1]<<8);}
static uint32_t u32(const unsigned char *p){return (uint32_t)p[0]|((uint32_t)p[1]<<8)|((uint32_t)p[2]<<16)|((uint32_t)p[3]<<24);}
void hrdbf_close(hrdbf_area *a){a->bytes=0;a->size=0;a->count=0;a->recno=0;a->nfields=0;a->open=0;a->bof=1;a->eof=1;}
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
hrdbf_error hrdbf_open(hrdbf_area *a,const unsigned char *b,size_t size){
 size_t i,end,pos=32;unsigned off=1,j,k,terminated=0;hrdbf_area tmp;hrdbf_value val;hrdbf_error err;
 hrdbf_close(a);hrdbf_close(&tmp);
 if(size<33)return HRDBF_FORMAT;
 if(b[0]!=3)return HRDBF_VERSION;
 /* No encrypted/transaction flags, structural index, memo or codepage mapping.
  * Codepage mark must be zero: bytes preserved, no conversion promise. */
 if(b[14]||b[15]||b[28]||b[29])return HRDBF_VERSION;
 tmp.header=u16(b+8);tmp.record=u16(b+10);tmp.count=u32(b+4);
 if(tmp.header<33||tmp.header>size||!tmp.record)return HRDBF_FORMAT;
 while(pos<tmp.header){
  hrdbf_field *f;
  if(b[pos]==13){terminated=1;pos++;break;}
  if(tmp.header-pos<32)return HRDBF_FORMAT;
  if(tmp.nfields==HRDBF_MAX_FIELDS)return HRDBF_LIMIT;
  f=&tmp.fields[tmp.nfields++];
  for(j=0;j<11;j++)f->name[j]=b[pos+j];
  if(!f->name[0])return HRDBF_FORMAT;
  for(j=0;j+1<tmp.nfields;j++){for(k=0;k<11&&tmp.fields[j].name[k]==f->name[k];k++);if(k==11)return HRDBF_FORMAT;}
  f->type=b[pos+11];f->width=b[pos+16];f->decimals=b[pos+17];f->offset=(uint16_t)off;
  if(!f->width)return HRDBF_FORMAT;
  if(f->type=='C'){if(f->decimals)return HRDBF_TYPE;}
  else if(f->type=='N'){if(f->decimals>17||f->decimals>=f->width)return HRDBF_LIMIT;}
  else if(f->type=='L'){if(f->width!=1||f->decimals)return HRDBF_FORMAT;}
  else if(f->type=='D'){if(f->width!=8||f->decimals)return HRDBF_FORMAT;}
  else return HRDBF_TYPE;
  off+=f->width;if(off>65535)return HRDBF_LIMIT;pos+=32;
 }
 if(!terminated||!tmp.nfields||off!=tmp.record)return HRDBF_FORMAT;
 while(pos<tmp.header)if(b[pos++])return HRDBF_FORMAT;
 if(tmp.count>(size-tmp.header)/tmp.record)return HRDBF_FORMAT;
 end=tmp.header+(size_t)tmp.count*tmp.record;
 if(end!=size&&(size-end!=1||b[end]!=26))return HRDBF_FORMAT;
 tmp.bytes=b;tmp.size=size;tmp.open=1;hrdbf_top(&tmp);
 /* Fail closed before exposing a cursor on malformed records. */
 for(i=0;i<tmp.count;i++){
  unsigned char mark=b[tmp.header+i*tmp.record];if(mark!=' '&&mark!='*')return HRDBF_DATA;
  tmp.recno=i+1;for(j=1;j<=tmp.nfields;j++){err=hrdbf_get(&tmp,j,&val);if(err)return err;}
 }
 hrdbf_top(&tmp);*a=tmp;return HRDBF_OK;
}
