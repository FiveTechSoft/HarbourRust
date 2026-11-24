#include "hrdyn.h"
/* Own MIT compiler-facing single-area adapter. */
#include "hrdbf_file.h"
#include "hrvalue.h"
#ifdef _WIN32
#define HRDBF_APP_PATH_MAX 260
#else
#define HRDBF_APP_PATH_MAX 4096
#endif
/* C static storage supplies zero-init by construction. No caller-init grant. */
static hrdbf_file hrdbf_app_state;
static hrntx_file hrdbf_app_order;
static uint64_t hrdbf_app_pos;
static unsigned hrdbf_app_found_flag;
/* x4: the single admitted order can be deselected (dbSetOrder(0) or an
 * order number outside the bag) while its entries stay open for a later
 * dbSetOrder(1) re-selection, exactly as Harbour keeps the bag open. */
static unsigned hrdbf_app_order_active;
static unsigned hrdbf_app_cdx;
static unsigned char hrdbf_app_basename[HRDBF_APP_PATH_MAX];
static size_t hrdbf_app_baselen;
/* D7: the saved path of the one admitted NTX index, for the close-time
 * flush of a dirty (rebuilt) index image. Empty for CDX bags, which stay
 * write-rejected. */
static char hrdbf_app_ntxpath[HRDBF_APP_PATH_MAX];
/* Structural CDX (measured against real Harbour, native Windows): a DBFCDX
 * open also opens <dir>/<base>.cdx whenever that file exists, with or
 * without the production flag in header byte 28; a missing file is silent.
 * The bag opens with no controlling order (natural order, AUTORDER 0);
 * dbSetOrder(1) selects it and ordListAdd() of the same bag selects it and
 * goes top. 0 none, 1 open bag, 2 present on a writable open (index writes
 * are outside this increment), 3 present but not admitted by the reader,
 * 4 present on a shared open (the index lock protocol is outside this
 * increment). */
static unsigned hrdbf_app_struct;
/* shared=.T. readonly=.T.: the table is snapshotted at open while other
 * processes may keep it open for writing; no index is admitted. */
static int hrdbf_app_shared;
/* Path character for "same file, other extension": ASCII case-insensitive,
 * and on Windows '\' and '/' are one separator. */
static unsigned char hrdbf_app_pathc(unsigned char c){
#ifdef _WIN32
 if(c=='\\')c='/';
#endif
 return cxupper(c);
}
static void hrdbf_app_write(const char *msg){
 size_t n=0;while(msg[n])n++;
#ifdef _WIN32
 {DWORD written;WriteFile(GetStdHandle(STD_ERROR_HANDLE),msg,(DWORD)n,&written,0);}
#else
 syscall3(1,2,(long)msg,n);
#endif
}
static void hrdbf_app_exit(void){
 hrntx_file_close(&hrdbf_app_order);
 hrdbf_file_close(&hrdbf_app_state);
#ifdef _WIN32
 ExitProcess(1);
#else
 syscall3(60,1,0,0);
#endif
 __builtin_unreachable();
}
static void hrdbf_app_fail(const char *msg){hrdbf_app_write(msg);hrdbf_app_exit();}
static void hrdbf_app_fail2(const char *prefix,const char *detail){
 hrdbf_app_write(prefix);hrdbf_app_write(detail);hrdbf_app_write("\n");hrdbf_app_exit();
}
static void hrdbf_app_require(void){if(!hrdbf_app_state.area.open)hrdbf_app_fail("hbc: DBF no workarea is open\n");}
void hrdbf_app_close(void){
 hrdbf_error a,b;
 if(hrntx_file_flush(&hrdbf_app_order,hrdbf_app_ntxpath))hrdbf_app_fail("hbc: DBF index flush failed\n");
 a=hrntx_file_close(&hrdbf_app_order);b=hrdbf_file_close(&hrdbf_app_state);
 hrdbf_app_found_flag=0;hrdbf_app_order_active=0;hrdbf_app_pos=0;hrdbf_app_struct=0;hrdbf_app_shared=0;hrdbf_app_ntxpath[0]=0;
 if(a||b)hrdbf_app_fail("hbc: DBF/NTX close failed\n");
}
void hrdbf_app_open(const unsigned char *p,size_t len,uint64_t new_area,uint64_t cdx,uint64_t writable){
 char path[HRDBF_APP_PATH_MAX];size_t i,start=0,end;hrdbf_error e;
 if(new_area&&hrdbf_app_state.area.open)hrdbf_app_fail("hbc: DBF only one workarea is supported\n");
 if(!len||len>=sizeof path)hrdbf_app_fail("hbc: DBF filename length outside supported range\n");
 for(i=0;i<len;i++){if(!p[i])hrdbf_app_fail("hbc: DBF filename contains NUL\n");path[i]=(char)p[i];}path[len]=0;
 if(hrntx_file_close(&hrdbf_app_order))hrdbf_app_fail("hbc: DBF index close failed\n");
 hrdbf_app_found_flag=0;hrdbf_app_order_active=0;hrdbf_app_pos=0;hrdbf_app_struct=0;hrdbf_app_ntxpath[0]=0;
 hrdbf_app_cdx=cdx!=0;
 /* writable: 0 readonly exclusive, 1 read-write exclusive, 2 readonly shared. */
 if(writable>2)hrdbf_app_fail("hbc: DBF open mode outside supported range\n");
 hrdbf_app_shared=writable==2;
 for(i=0;i<len;i++)if(p[i]=='/'
#ifdef _WIN32
 ||p[i]=='\\'
#endif
 )start=i+1;
 end=len;for(i=start;i<len;i++)if(p[i]=='.')end=i;
 /* The table path without its extension (pathc-folded): an index with the
  * same stem is the structural bag, one in another directory is not. */
 hrdbf_app_baselen=end;
 for(i=0;i<end;i++)hrdbf_app_basename[i]=hrdbf_app_pathc(p[i]);
 e=hrdbf_file_open(&hrdbf_app_state,path,(int)writable);
 if(e){
  /* D1.1: exact reason from the OS layer or the decoder, code fallback. */
  const char *d=hrdbf_app_state.diag[0]?hrdbf_app_state.diag:hrdbf_app_state.area.diag;
  if(!d[0])d=e==HRDBF_IO?"I/O error":e==HRDBF_MEMORY?"out of memory":
            e==HRDBF_LIMIT?"size or field-count limit exceeded":
            e==HRDBF_VERSION?"unsupported table version or header flags":
            e==HRDBF_TYPE?"unsupported field type":
            e==HRDBF_DATA?"record content invalid":"table format not supported";
  hrdbf_app_fail2("hbc: DBF open rejected: ",d);
 }
 if(hrdbf_app_cdx&&end+4<sizeof path){
  path[end]='.';path[end+1]='c';path[end+2]='d';path[end+3]='x';path[end+4]=0;
  if(!hrntx_file_missing(path)){
   if(writable==1)hrdbf_app_struct=2;
   else if(hrdbf_app_shared)hrdbf_app_struct=4;
   else hrdbf_app_struct=hrntx_file_open(&hrdbf_app_order,path,&hrdbf_app_state.area,1)?3:1;
  }
 }
}
static void hrdbf_app_struct_check(void){
 if(hrdbf_app_struct==2)hrdbf_app_fail("hbc: structural CDX on a readonly=.F. open is outside this increment (index maintenance)\n");
 if(hrdbf_app_struct==3)hrdbf_app_fail("hbc: structural CDX present but not admitted (one tag, subset, size or format)\n");
 if(hrdbf_app_struct==4)hrdbf_app_fail("hbc: structural CDX on a shared=.T. open is outside this increment (index lock protocol)\n");
}
static void hrdbf_app_order_sync(void){
 hrdbf_area*d=&hrdbf_app_state.area;hrntx_index*x=&hrdbf_app_order.index;
 d->recno=hrdbf_app_pos<x->count?x->entries[hrdbf_app_pos].recno:(uint64_t)d->count+1;
 d->eof=hrdbf_app_pos>=x->count;
}
void hrdbf_app_top(void){
 hrdbf_app_require();hrdbf_app_found_flag=0;
 if(!(hrdbf_app_order.index.bytes&&hrdbf_app_order_active)){hrdbf_top(&hrdbf_app_state.area);return;}
 hrdbf_app_pos=0;hrdbf_app_order_sync();hrdbf_app_state.area.bof=!hrdbf_app_order.index.count;
}
void hrdbf_app_bottom(void){
 hrdbf_area*d=&hrdbf_app_state.area;hrntx_index*x=&hrdbf_app_order.index;
 hrdbf_app_require();hrdbf_app_found_flag=0;
 if(!(x->bytes&&hrdbf_app_order_active)){d->recno=d->count?d->count:1;d->bof=d->eof=!d->count;return;}
 hrdbf_app_pos=x->count?x->count-1:0;hrdbf_app_order_sync();d->bof=!x->count;
}
void hrdbf_app_skip(int64_t n){
 hrdbf_area*d=&hrdbf_app_state.area;hrntx_index*x=&hrdbf_app_order.index;uint64_t m;
 hrdbf_app_require();hrdbf_app_found_flag=0;
 if(!(x->bytes&&hrdbf_app_order_active)){hrdbf_skip(d,n);return;}
 if(!n)return;
 d->bof=0;
 if(n>0){m=(uint64_t)n;hrdbf_app_pos=m>x->count-hrdbf_app_pos?x->count:hrdbf_app_pos+m;}
 else{m=(uint64_t)(-(n+1))+1;if(m>hrdbf_app_pos){hrdbf_app_pos=0;d->bof=1;}else hrdbf_app_pos-=m;}
 hrdbf_app_order_sync();
}
uint64_t hrdbf_app_order_add(const unsigned char*p,size_t len){
 char path[HRDBF_APP_PATH_MAX];size_t i,last=0,end;int dot=0,same=1;hrdbf_error err;
 hrdbf_app_require();
 if(!len||len>sizeof(path)-5)hrdbf_app_fail("hbc: DBF index filename length outside supported range\n");
 for(i=0;i<len;i++){if(!p[i])hrdbf_app_fail("hbc: DBF index filename contains NUL\n");path[i]=(char)p[i];if(p[i]=='/'
#ifdef _WIN32
 ||p[i]=='\\'
#endif
 )last=i+1;}
 end=len;for(i=last;i<len;i++)if(p[i]=='.'){dot=1;end=i;}
 if(hrdbf_app_cdx&&end==hrdbf_app_baselen){
  for(i=0;i<end;i++)if(hrdbf_app_pathc(p[i])!=hrdbf_app_basename[i])same=0;
 }else same=0;
 /* The structural bag is already open: Harbour selects its order and goes
  * top (measured), it does not open a second copy. */
 if(same&&hrdbf_app_struct==1){hrdbf_app_order_active=1;hrdbf_app_top();return 1;}
 if(same)hrdbf_app_struct_check();
 if(hrdbf_app_shared)hrdbf_app_fail("hbc: DBF index on a shared=.T. open is outside this increment (index lock protocol)\n");
 if(hrdbf_app_order.index.bytes)hrdbf_app_fail("hbc: DBF index only one index is supported\n");
 if(!dot){path[len++]='.';path[len++]=hrdbf_app_cdx?'c':'n';path[len++]=hrdbf_app_cdx?'d':'t';path[len++]='x';}path[len]=0;
 err=hrntx_file_open(&hrdbf_app_order,path,&hrdbf_app_state.area,hrdbf_app_cdx);
 if(err)hrdbf_app_fail(hrdbf_app_cdx&&err==HRDBF_TYPE?"hbc: CDX direct character key field width must be <=240\n":"hbc: DBF index read-only open rejected (subset, format, DBF mismatch, size or I/O)\n");
 if(!hrdbf_app_cdx){size_t k;for(k=0;k<=len&&k<sizeof hrdbf_app_ntxpath;k++)hrdbf_app_ntxpath[k]=path[k];}
 else hrdbf_app_ntxpath[0]=0;
 hrdbf_app_order_active=1;hrdbf_app_top();return 1;
}
void hrdbf_app_order_clear(void){
 hrdbf_app_require();
 if(hrntx_file_flush(&hrdbf_app_order,hrdbf_app_ntxpath))hrdbf_app_fail("hbc: DBF index flush failed\n");
 if(hrntx_file_close(&hrdbf_app_order))hrdbf_app_fail("hbc: DBF index close failed\n");
 hrdbf_app_order_active=0;hrdbf_app_pos=0;hrdbf_app_ntxpath[0]=0;
}
uint64_t hrdbf_app_found(void){hrdbf_app_require();return hrdbf_app_found_flag;}
uint64_t hrdbf_app_seek(const unsigned char*p,size_t n,uint64_t soft,uint64_t last){
 int found;hrntx_index*x=&hrdbf_app_order.index;hrdbf_app_require();
 /* Harbour DBFNTX/1201: a seek without the controlling order is a
  * run-time error, not a natural-order scan; the bag may still be open
  * after dbSetOrder(0), so the active flag is what decides here. */
 if(!(x->bytes&&hrdbf_app_order_active))hrdbf_app_fail("hbc: DBF index seek requires an open index\n");
 hrdbf_app_pos=hrntx_seek(x,p,n,soft!=0,last!=0,&found);hrdbf_app_found_flag=found;hrdbf_app_order_sync();hrdbf_app_state.area.bof=!hrdbf_app_cdx&&!x->count;return found;
}
/* Dyn seek entry: a field read or a Dyn local. Measured against real
 * Harbour (o7-o14, native Windows):
 * - character cells (owned/borrowed, length header at payload[-1]) seek
 *   by bytes, width-truncated like the ordinary path;
 * - numeric cells convert to a ZERO-padded integer key string with the
 *   index key width: the value rounds half away from zero first
 *   (3.4->"000003", 3.6->"000004", 2.5->"000003", -1 below the range);
 * - every other kind (NIL, logical, date) is a guaranteed miss with the
 *   cursor past the last entry (recno count+1, Eof .T., Found .F.) for
 *   soft and hard seeks alike.
 * The zero-pad does not truncate: a value wider than the key simply
 * sorts past the range, exactly like the literal form. */
static void hrdbf_app_seek_miss_end(hrntx_index *x){
 hrdbf_app_pos=x->count;hrdbf_app_found_flag=0;hrdbf_app_order_sync();hrdbf_app_state.area.bof=!hrdbf_app_cdx&&!x->count;
}
static size_t hrdbf_app_pad_ll(long long r,unsigned width,char *buf){
 unsigned char tmp[24];size_t n=0,i,len,zeros;int neg=r<0;unsigned long long m=neg?(unsigned long long)(-(r+1))+1:(unsigned long long)r;
 if(!m)tmp[n++]='0';
 while(m){tmp[n++]=(unsigned char)('0'+(m%10));m/=10;}
 len=0;
 if(neg)buf[len++]='-';
 zeros=(size_t)width-n-len;
 for(i=0;i<zeros;i++)buf[len++]='0';
 for(i=n;i>0;i--)buf[len++]=tmp[i-1];
 return len;
}
uint64_t hrdbf_app_seek_dyn(uint64_t tag,uint64_t pay,uint64_t soft,uint64_t last){
 unsigned k=(unsigned)(tag&255u);hrntx_index*x=&hrdbf_app_order.index;hrdbf_app_require();
 if(!(x->bytes&&hrdbf_app_order_active))hrdbf_app_fail("hbc: DBF index seek requires an open index\n");
 if(k==HRV_STR_OWN||k==HRV_STR_BORROW){
  if(!pay)hrdbf_app_fail("hbc: DBF index seek expects a character key value\n");
  return hrdbf_app_seek((const unsigned char*)pay,(size_t)((const uint64_t*)pay)[-1],soft,last);
 }
 if(k==HRV_I64||k==HRV_I64_LITERAL){
  char buf[280];size_t n=hrdbf_app_pad_ll((long long)(int64_t)pay,x->width,buf);
  return hrdbf_app_seek((const unsigned char*)buf,n,soft,last);
 }
 if(k==HRV_DOUBLE){
  union{uint64_t u;double d;}z;z.u=(tag&HR_DYN_FLOAT_HEAP)?((const uint64_t*)pay)[0]:pay;
  double v=z.d;long long r;
  char buf[280];size_t n;
  if(v>9.2e18)r=(long long)9223372036854775807LL;else if(v<-9.2e18)r=(-9223372036854775807LL-1);
  else r=v<0?(long long)(v-0.5):(long long)(v+0.5);
  n=hrdbf_app_pad_ll(r,x->width,buf);
  return hrdbf_app_seek((const unsigned char*)buf,n,soft,last);
 }
 if(k==HRV_FIELD_NUMERIC){
  hrv_cell c={tag,pay};unsigned d=hrv_decimals(c);double v=(double)(int64_t)pay;long long r;
  char buf[280];size_t n;
  while(d--)v/=10.0;
  if(v>9.2e18)r=(long long)9223372036854775807LL;else if(v<-9.2e18)r=(-9223372036854775807LL-1);
  else r=v<0?(long long)(v-0.5):(long long)(v+0.5);
  n=hrdbf_app_pad_ll(r,x->width,buf);
  return hrdbf_app_seek((const unsigned char*)buf,n,soft,last);
 }
 hrdbf_app_seek_miss_end(x);return 0;
}
uint64_t hrdbf_app_recno(void){hrdbf_app_require();return hrdbf_app_state.area.recno;}
uint64_t hrdbf_app_lastrec(void){hrdbf_app_require();return hrdbf_app_state.area.count;}
uint64_t hrdbf_app_fcount(void){hrdbf_app_require();return hrdbf_app_state.area.nfields;}
/* x5: dbGoto(n), measured against real Harbour (native Windows, o1/o3):
 * n in 1..LastRec() -> physical record n, Eof/Bof .F., Found() reset; with
 * the controlling order selected the index cursor is re-planted on record
 * n's entry (a following dbSkip follows the order). n<=0 or n>LastRec()
 * -> record count+1 with BOTH Eof and Bof .T. in every measured case,
 * natural or indexed; the indexed cursor rests past the last entry so a
 * following dbSkip(-1) walks back to the last entry. Every admitted index
 * contains every record, so an exact entry always exists for 1..count. */
static void hrdbf_app_cursor_replant(uint64_t rec){
 hrntx_index*x=&hrdbf_app_order.index;uint32_t i;
 for(i=0;i<x->count;i++)if(x->entries[i].recno==rec){hrdbf_app_pos=i;return;}
 hrdbf_app_pos=x->count;
}
void hrdbf_app_goto(int64_t n){
 hrdbf_area*d=&hrdbf_app_state.area;hrntx_index*x=&hrdbf_app_order.index;
 hrdbf_app_require();hrdbf_app_found_flag=0;
 if(n<1||(uint64_t)n>d->count){d->recno=(uint64_t)d->count+1;d->eof=1;d->bof=1;}
 else{d->recno=(uint64_t)n;d->eof=0;d->bof=0;}
 if(x->bytes&&hrdbf_app_order_active)hrdbf_app_cursor_replant(d->recno);
}
/* x4: dbSetOrder(n) with a one-entry bag (measured o2/o4/o5): n==1 selects
 * the open order and re-plants the index cursor on the current record's
 * entry; n==0 and any other number deselect (natural order, bag open,
 * record pointer, Eof/Bof and Found() all untouched). Re-selection needs
 * no movement, so dbSetOrder itself never moves or resets anything. */
void hrdbf_app_ordselect(int64_t n){
 hrdbf_area*d=&hrdbf_app_state.area;hrntx_index*x=&hrdbf_app_order.index;
 hrdbf_app_require();
 if(n>=1&&!x->bytes)hrdbf_app_struct_check();
 if(n!=1||!x->bytes){hrdbf_app_order_active=0;return;}
 hrdbf_app_order_active=1;hrdbf_app_cursor_replant(d->recno);
}
uint64_t hrdbf_app_bof(void){hrdbf_app_require();return hrdbf_app_state.area.bof;}
uint64_t hrdbf_app_eof(void){hrdbf_app_require();return hrdbf_app_state.area.eof;}
uint64_t hrdbf_app_deleted(void){unsigned char d;hrdbf_app_require();hrdbf_deleted(&hrdbf_app_state.area,&d);return d;}
/* Harbour BASE/1003 equivalent for a bare field identifier: explicit
 * fail-fast naming the missing field, never a silent NIL. */
static const char hrdbf_app_pre_field[]="hbc: DBF field not found in the open area: ";
static void hrdbf_app_field_missing(const unsigned char *p,size_t len){
#ifdef _WIN32
 {DWORD w;WriteFile(GetStdHandle(STD_ERROR_HANDLE),hrdbf_app_pre_field,(DWORD)(sizeof hrdbf_app_pre_field-1),&w,0);
  WriteFile(GetStdHandle(STD_ERROR_HANDLE),p,(DWORD)len,&w,0);
  WriteFile(GetStdHandle(STD_ERROR_HANDLE),"\n",1,&w,0);}
#else
 syscall3(1,2,(long)hrdbf_app_pre_field,sizeof hrdbf_app_pre_field-1);
 syscall3(1,2,(long)p,len);
 syscall3(1,2,(long)"\n",1);
#endif
 hrntx_file_close(&hrdbf_app_order);
 hrdbf_file_close(&hrdbf_app_state);
#ifdef _WIN32
 ExitProcess(1);
#else
 syscall3(60,1,0,0);
#endif
 __builtin_unreachable();
}
static hrv_cell hrdbf_app_get_ord(int64_t n,void *(*copy)(const void*,size_t)){
 hrdbf_value v;hrv_cell c={HRV_NIL,0};unsigned char spaces[255];size_t i;
 hrdbf_app_require();
 if(n<1||n>hrdbf_app_state.area.nfields)return c;
 if(hrdbf_get(&hrdbf_app_state.area,(unsigned)n,&v))hrdbf_app_fail("hbc: DBF field decoding failed\n");
 if(v.type=='C'){
  if(!v.text){for(i=0;i<v.width;i++)spaces[i]=' ';v.text=spaces;}
  c.tag=HRV_STR_OWN;c.payload=(uint64_t)copy(v.text,v.width);if(!c.payload)hrdbf_app_fail("hbc: DBF field string allocation failed\n");return c;
 }
 if(v.type=='N')return hrv_number(v.scaled,v.width,v.decimals);
 if(v.type=='D')return hrv_date(v.date);
 c.tag=HRV_LOGICAL;c.payload=v.logical;return c;
}
hrv_cell hrdbf_app_get(int64_t n,void *(*copy)(const void*,size_t)){
 return hrdbf_app_get_ord(n,copy);
}
/* Bare field identifier: case-insensitive name lookup against the open
 * workarea, then the ordinary ordinal path. Field names are NUL-padded in
 * the header; the source identifier carries no padding. */
hrv_cell hrdbf_app_get_name(const unsigned char *p,size_t len,void *(*copy)(const void*,size_t)){
 const hrdbf_area *a=&hrdbf_app_state.area;unsigned i;size_t j;
 hrdbf_app_require();
 for(i=0;i<a->nfields;i++){
  const unsigned char *nm=a->fields[i].name;size_t nl=0;
  while(nl<sizeof a->fields[i].name&&nm[nl])nl++;
  if(nl!=len)continue;
  for(j=0;j<len;j++)if(cxupper(p[j])!=cxupper(nm[j]))break;
  if(j==len)return hrdbf_app_get_ord((int64_t)i+1,copy);
 }
 hrdbf_app_field_missing(p,len);
 __builtin_unreachable();
}
/* D2: field writes (encoders ported from OpenADS dbf_common.cpp, MIT).
 * Writes mutate the owned snapshot through hrdbf_write_* and commit back
 * immediately (hrdbf_file_write_record), matching Harbour exclusive-mode
 * visibility. Admitted value matrix is same-type only: C<-string,
 * N<-numeric kinds, D<-Date, L<-logical; anything else fails fast naming
 * the mismatch, never a silent conversion. A write with an open index is
 * outside this increment (indexes stay read-only snapshots). */
#include "hrdbf_write.h"
static void hrdbf_app_require_writable(void){
 hrdbf_app_require();
 if(!hrdbf_app_state.writable)hrdbf_app_fail("hbc: DBF field write requires a readonly=.F. open\n");
 /* D7: an open NTX index is maintained on writes (rebuild at the key
  * write, flush at close); an open CDX bag stays write-rejected. */
 if(hrdbf_app_order.index.bytes&&hrdbf_app_cdx)hrdbf_app_fail("hbc: DBF field write with an open CDX index is outside this increment (NTX only)\n");
}
/* D7: rebuild the live NTX index from the current table snapshot after a
 * key change (oracle-measured: the new key is visible to dbSeek
 * immediately, the old key is gone, and the change persists over
 * close/reopen). The cursor re-parks on the current record's entry, or
 * past the last one at EOF. */
static void hrdbf_app_rebuild_index(void){
 hrntx_index*x=&hrdbf_app_order.index;uint64_t r;size_t i;
 if(!x->bytes||hrdbf_app_cdx)return;
 if(hrntx_file_rebuild(&hrdbf_app_order,&hrdbf_app_state.area))hrdbf_app_fail("hbc: DBF NTX index rebuild failed\n");
 r=hrdbf_app_state.area.recno;hrdbf_app_pos=x->count;
 for(i=0;i<x->count;i++)if(x->entries[i].recno==r){hrdbf_app_pos=i;break;}
 hrdbf_app_order_sync();
}
void hrdbf_app_fieldput(int64_t n,uint64_t tag,uint64_t pay){
 hrdbf_file *f=&hrdbf_app_state;const hrdbf_field *fd;unsigned char *rec;
 unsigned k;hrdbf_error e=HRDBF_OK;hrv_cell c={tag,pay};
 hrdbf_app_require_writable();
 if(n<1||n>f->area.nfields)hrdbf_app_fail("hbc: DBF field ordinal outside the open area\n");
 fd=&f->area.fields[n-1];
 rec=f->owned+f->area.header+(size_t)(f->area.recno-1)*f->area.record;
 k=hrv_kind(c);
 switch(fd->type){
 case 'C':
  if(k==HRV_STR_OWN||k==HRV_STR_BORROW)e=hrdbf_write_char(rec,fd,(const unsigned char*)pay,((const uint64_t*)pay)[-1]);
  else if(k==HRV_NIL)e=hrdbf_write_blank(rec,fd);
  else e=HRDBF_TYPE;
  break;
 case 'N':
  if(k==HRV_FIELD_NUMERIC)e=hrdbf_write_number_scaled(rec,fd,(int64_t)pay,hrv_decimals(c));
  else if(k==HRV_I64||k==HRV_I64_LITERAL)e=hrdbf_write_number_scaled(rec,fd,(int64_t)pay,0);
  else if(k==HRV_DOUBLE){union{uint64_t u;double d;}v;v.u=(tag&HR_DYN_FLOAT_HEAP)?((const uint64_t*)pay)[0]:pay;e=hrdbf_write_number_double(rec,fd,v.d);}
  else if(k==HRV_NIL)e=hrdbf_write_blank(rec,fd);
  else e=HRDBF_TYPE;
  break;
 case 'D':
  if(k==HRV_DATE)e=hrdbf_write_date(rec,fd,(uint32_t)pay);
  else if(k==HRV_NIL)e=hrdbf_write_blank(rec,fd);
  else e=HRDBF_TYPE;
  break;
 case 'L':
  if(k==HRV_LOGICAL)e=hrdbf_write_logical(rec,fd,(unsigned char)(pay!=0));
  else if(k==HRV_NIL)e=hrdbf_write_blank(rec,fd);
  else e=HRDBF_TYPE;
  break;
 default:e=HRDBF_TYPE;break;
 }
 if(e==HRDBF_TYPE)hrdbf_app_fail("hbc: DBF field write type mismatch\n");
 if(e)hrdbf_app_fail("hbc: DBF field write encoding rejected\n");
 if(hrdbf_file_write_record(f,f->area.recno))hrdbf_app_fail("hbc: DBF field write commit failed\n");
 if(hrdbf_app_order.index.bytes&&!hrdbf_app_cdx&&(uint64_t)n==hrdbf_app_order.index.field+1)hrdbf_app_rebuild_index();
}
/* D6: delete-flag writes. Oracle-measured (Harbour 3.2 mingw64 native,
 * November 24, 2026): dbDelete marks rec[0]='*' and dbRecall marks ' '
 * on the CURRENT record with the same immediate-commit contract as the
 * field writes (D2); Deleted() reports it through the existing reader.
 * At EOF (recno > LastRec) the oracle dbDelete is a silent no-op
 * (d6_eof probe: Eof()=.T., Deleted() stays .F., rc=0), so the
 * positioned-record check of the field-write path is NOT a named
 * failure here. A readonly open keeps the named rejection (the oracle
 * raises DBFCDX/1025 "Write not allowed" at a positioned record;
 * hbc names it at compile time like every write in this increment).
 * Writes with an open index stay rejected (index propagation is D7). */
static void hrdbf_app_require_flag_writable(void){
 hrdbf_app_require();
 if(!hrdbf_app_state.writable)hrdbf_app_fail("hbc: DBF delete/recall requires a readonly=.F. open\n");
 if(hrdbf_app_order.index.bytes&&hrdbf_app_cdx)hrdbf_app_fail("hbc: DBF delete/recall with an open CDX index is outside this increment (NTX only)\n");
}
void hrdbf_app_delete(void){
 unsigned char *rec;
 hrdbf_app_require_flag_writable();
 if(hrdbf_app_state.area.recno>hrdbf_app_state.area.count)return;
 rec=hrdbf_app_state.owned+hrdbf_app_state.area.header+(size_t)(hrdbf_app_state.area.recno-1)*hrdbf_app_state.area.record;
 hrdbf_write_deleted(rec,1);
 if(hrdbf_file_write_record(&hrdbf_app_state,hrdbf_app_state.area.recno))hrdbf_app_fail("hbc: DBF delete commit failed\n");
}
void hrdbf_app_recall(void){
 unsigned char *rec;
 hrdbf_app_require_flag_writable();
 if(hrdbf_app_state.area.recno>hrdbf_app_state.area.count)return;
 rec=hrdbf_app_state.owned+hrdbf_app_state.area.header+(size_t)(hrdbf_app_state.area.recno-1)*hrdbf_app_state.area.record;
 hrdbf_write_deleted(rec,0);
 if(hrdbf_file_write_record(&hrdbf_app_state,hrdbf_app_state.area.recno))hrdbf_app_fail("hbc: DBF recall commit failed\n");
}
/* D6: dbCommit is a named no-op. Oracle-measured (d6_sem/d6_commit
 * probes): dbCommit() and dbCommit(1) on a writable exclusive open
 * print nothing and return 0; the adapter's writes are already
 * synchronous (field/record writes hit the OS immediately). Reopen
 * persistence was measured the same way: a marked record stays marked
 * after dbCloseArea + dbUseArea (the '*' is in the file). */
void hrdbf_app_commit(void){}

/* Bare field identifier write: same case-insensitive lookup as get_name. */void hrdbf_app_set_name(const unsigned char *p,size_t len,uint64_t tag,uint64_t pay){
 const hrdbf_area *a=&hrdbf_app_state.area;unsigned i;size_t j;
 hrdbf_app_require_writable();
 for(i=0;i<a->nfields;i++){
  const unsigned char *nm=a->fields[i].name;size_t nl=0;
  while(nl<sizeof a->fields[i].name&&nm[nl])nl++;
  if(nl!=len)continue;
  for(j=0;j<len;j++)if(cxupper(p[j])!=cxupper(nm[j]))break;
  if(j==len){hrdbf_app_fieldput((int64_t)i+1,tag,pay);return;}
 }
 hrdbf_app_field_missing(p,len);
}
/* D2: APPEND BLANK primitive: blank record, EOF marker, header count and
 * UTC date rewrite; the cursor moves to the new record. */
uint64_t hrdbf_app_append(void){
 uint32_t recno;
 hrdbf_app_require_writable();
 if(hrdbf_file_append(&hrdbf_app_state,&recno))hrdbf_app_fail("hbc: DBF append failed\n");
 hrdbf_app_found_flag=0;
 hrdbf_app_rebuild_index();
 return recno;
}
size_t hrdbf_app_render(uint64_t tag,uint64_t pay,unsigned char *out){
 hrv_cell c={tag,pay};size_t n=0;hrv_error e=hrv_render(c,out,256,&n);
 if(e)hrdbf_app_fail("hbc: DBF scalar render rejected\n");return n;
}
int64_t hrdbf_app_integer(uint64_t tag,uint64_t pay){
 hrv_cell c={tag,pay};int64_t n;hrv_error e=hrv_i64(c,&n);
 if(e==HRV_DECIMAL_I64)hrdbf_app_fail("hbc: DBF decimal numeric cannot enter I64 operation\n");
 if(e)hrdbf_app_fail("hbc: DBF scalar cannot enter I64 operation\n");return n;
}
uint64_t hrdbf_app_equal(uint64_t ta,uint64_t pa,uint64_t tb,uint64_t pb){
 hrv_cell a={ta,pa},b={tb,pb};int yes;hrv_error e=hrv_equal(a,b,&yes);
 if(e)hrdbf_app_fail("hbc: DBF scalar comparison is outside this increment\n");return (uint64_t)yes;
}
/* D4: ordering comparisons widen numerics by value (hrv_compare); the
 * DATE x DATE arm stays here. A decimal field or a float cell against a
 * non-numeric is the same clean typed failure as before (Harbour's
 * BASE/1073-1076 dialog is the registered failure-mode difference). */
int64_t hrdbf_app_compare(uint64_t ta,uint64_t pa,uint64_t tb,uint64_t pb){
 hrv_cell a={ta,pa},b={tb,pb};int64_t r;hrv_error e;
 if(hrv_kind(a)==HRV_DATE&&hrv_kind(b)==HRV_DATE){if(hrv_validate(a)||hrv_validate(b))hrdbf_app_fail("hbc: DBF invalid Date comparison\n");return pa<pb?-1:pa>pb;}
 e=hrv_compare(a,b,&r);if(e)hrdbf_app_fail("hbc: DBF scalar comparison is outside this increment\n");return r;
}
uint64_t hrdbf_app_empty(uint64_t t,uint64_t p){
 hrv_cell c={t,p};unsigned k=hrv_kind(c);int yes;hrv_error e;
 if(k==HRV_STR_OWN||k==HRV_STR_BORROW){size_t i,n=((const uint64_t*)p)[-1];const unsigned char*s=(const unsigned char*)p;for(i=0;i<n;i++)if(s[i]!=' '&&s[i]!=9&&s[i]!=10&&s[i]!=13)return 0;return 1;}
 if(k==HRV_ARRAY)return !p||!((const uint64_t*)p)[-1];
 if(k==HRV_DOUBLE){union{uint64_t u;double d;}v;v.u=(t&HR_DYN_FLOAT_HEAP)?((const uint64_t*)p)[0]:p;return v.d==0.0;}
 if(k==HRV_BLOCK)return 0;
 e=hrv_empty(c,&yes);if(e)hrdbf_app_fail("hbc: DBF scalar Empty rejected\n");return (uint64_t)yes;
}
/* D3: Dyn numeric arithmetic entry point. The compiler emits this call for
 * +,-,*,/ with a Dyn operand while DBF is active; the result rides back as
 * the (tag,pay) pair in rax:rdx (SysV struct return), an integer cell on the
 * fast path or a legacy inline float cell after widening. */
hrv_cell hrdbf_app_arith(uint64_t op,uint64_t ta,uint64_t pa,uint64_t tb,uint64_t pb){
 hrv_cell a={ta,pa},b={tb,pb},r;hrv_error e=hrv_arith((unsigned)op,a,b,&r);
 if(e==HRV_ZERODIV)hrdbf_app_fail("hbc: DBF arithmetic division by zero\n");
 if(e==HRV_TYPE)hrdbf_app_fail("hbc: DBF arithmetic on a NIL or non-numeric operand\n");
 if(e)hrdbf_app_fail("hbc: DBF arithmetic rejected\n");
 return r;
}
void hrdbf_app_unsupported(void){hrdbf_app_fail("hbc: DBF-active dynamic scalar consumer is outside the admitted subset\n");}
