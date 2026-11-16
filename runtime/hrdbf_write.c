/* Field write encoders for the owned mutable DBF snapshot.
 * Ported from OpenADS (MIT License), Copyright (c) 2026 OpenADS
 * contributors, src/drivers/dbf_common.cpp (encode_field_string /
 * encode_field_double / encode_field_logical / encode_field_null and
 * set_record_deleted). HarbourRust adaptations: freestanding C99 with no
 * libc, no locale, no allocation; the double formatter is an own exact
 * bignum implementation of "%.*f" rounding (half-even on the exact binary
 * value) instead of snprintf. Harbour remains the behavioral oracle. */
#include "hrdbf_write.h"

/* ---- small exact bignum (little-endian limbs), no allocation ---------- */
#define HRBN_LIMBS 72 /* 2304 bits: 53-bit mantissa * 5^340, shifted <= 1311 */
typedef struct { uint32_t w[HRBN_LIMBS]; unsigned n; } hrbn;

static void bn_set64(hrbn *a, uint64_t v){
 a->w[0]=(uint32_t)v;a->w[1]=(uint32_t)(v>>32);a->n=a->w[1]?2:1;
}
static void bn_mul32(hrbn *a, uint32_t m){
 uint64_t c=0;unsigned i;
 for(i=0;i<a->n;i++){c+=(uint64_t)a->w[i]*m;a->w[i]=(uint32_t)c;c>>=32;}
 if(c)a->w[a->n++]=(uint32_t)c;
}
static void bn_shl(hrbn *a, unsigned bits){
 unsigned q=bits/32,r=bits%32,i;uint32_t carry=0;
 if(a->n+q>=HRBN_LIMBS)return; /* unreachable: sized for the double range */
 if(r){
  for(i=0;i<a->n;i++){uint32_t nv=(a->w[i]<<r)|carry;carry=a->w[i]>>(32-r);a->w[i]=nv;}
  if(carry)a->w[a->n++]=carry;
 }
 if(q){for(i=a->n;i-- >0;)a->w[i+q]=a->w[i];for(i=0;i<q;i++)a->w[i]=0;a->n+=q;}
}
static unsigned bn_bit(const hrbn *a,unsigned i){
 return i<a->n*32?(a->w[i/32]>>(i%32))&1u:0u;
}
/* a >>= k, reporting the dropped remainder class vs 2^(k-1):
 * 0 zero, 1 below half, 2 exactly half, 3 above half. */
static unsigned bn_shr_round(hrbn *a, unsigned k){
 unsigned q=k/32,r=k%32,i,cls;
 if(!k)return 0;
 if(k>=a->n*32){
  /* the whole value drops out: compare it against 2^(k-1) */
  unsigned top=0,any=0,nbits=0;
  for(i=0;i<a->n*32;i++)if(bn_bit(a,i)){any=1;top=i;}
  if(!any)cls=0;
  else{
   nbits=0;for(i=0;i<a->n*32;i++)nbits+=bn_bit(a,i);
   if(top<k-1)cls=1;
   else if(top==k-1)cls=nbits==1?2:3;
   else cls=3;
  }
  a->n=1;a->w[0]=0;return cls;
 }
 /* dropped = low k bits; half bit is bit k-1 */
 {
  unsigned half=bn_bit(a,k-1),below=0;
  for(i=0;i+1<k;i++)if(bn_bit(a,i)){below=1;break;}
  if(!half)cls=below?1:0;
  else cls=below?3:2;
 }
 if(q){
  for(i=0;i+q<a->n;i++)a->w[i]=a->w[i+q];
  a->n-=q;for(i=a->n;i<a->n+q;i++)a->w[i]=0;
 }
 if(r){
  for(i=0;i+1<a->n;i++)a->w[i]=(a->w[i]>>r)|(a->w[i+1]<<(32-r));
  a->w[a->n-1]>>=r;
  if(!a->w[a->n-1]&&a->n>1)a->n--;
 }
 return cls;
}
static void bn_inc(hrbn *a){
 uint64_t c=1;unsigned i;
 for(i=0;i<a->n;i++){c+=a->w[i];a->w[i]=(uint32_t)c;c>>=32;}
 if(c)a->w[a->n++]=(uint32_t)c;
}
/* <0 / 0 / >0 comparison. */
static int bn_cmp(const hrbn *a,const hrbn *b){
 unsigned i;
 if(a->n!=b->n)return a->n<b->n?-1:1;
 for(i=a->n;i-- >0;)if(a->w[i]!=b->w[i])return a->w[i]<b->w[i]?-1:1;
 return 0;
}
static uint32_t bn_divmod_1e9(hrbn *a){
 uint64_t cur=0;unsigned i;
 for(i=a->n;i-- >0;){cur=(cur<<32)|a->w[i];a->w[i]=(uint32_t)(cur/1000000000u);cur%=1000000000u;}
 while(a->n>1&&!a->w[a->n-1])a->n--;
 return (uint32_t)cur;
}

/* ---- correctly-rounded fixed formatter ("%.<dec>f") --------------------
 * N = round(value * 10^dec) as an exact integer (half-even on the exact
 * binary value), then decimal rendering with exactly dec fraction digits.
 * Returns the byte length, or 0 for inf/nan or insufficient cap. */
unsigned hrdbf_fmt_fixed(unsigned char *out, unsigned cap, double value,
                         unsigned dec){
 union { double d; uint64_t u; } v;uint64_t m;int e2;long shift;
 hrbn a;uint32_t groups[48];unsigned ng=0,neg,i,j,pos;
 unsigned char digits[352];unsigned nd=0;
 if(dec>32)return 0;
 v.d=value;
 neg=(unsigned)(v.u>>63);
 if(((v.u>>52)&0x7ff)==0x7ff)return 0; /* inf/nan: unencodable */
 if(!((v.u>>52)&0x7ff)){e2=-1074;m=v.u&0xfffffffffffffu;}
 else{e2=(int)((v.u>>52)&0x7ff)-1075;m=(v.u&0xfffffffffffffu)|0x10000000000000u;}
 if(!m){
  pos=0;
  if(neg){if(cap<1)return 0;out[pos++]='-';}
  if(pos+1+(dec?1+dec:0)>cap)return 0;
  out[pos++]='0';
  if(dec){out[pos++]='.';for(i=0;i<dec;i++)out[pos++]='0';}
  return pos;
 }
 bn_set64(&a,m);
 for(i=0;i<dec;i++)bn_mul32(&a,5);
 shift=(long)e2+(long)dec;
 if(shift>=0)bn_shl(&a,(unsigned)shift);
 else{
  unsigned cls=bn_shr_round(&a,(unsigned)-shift);
  if(cls==3||(cls==2&&(a.w[0]&1u)))bn_inc(&a);
 }
 while(!(a.n==1&&!a.w[0])&&ng<48)groups[ng++]=bn_divmod_1e9(&a);
 if(!ng)groups[ng++]=0;
 {
  unsigned g=ng;
  uint32_t first;char buf[10];unsigned b=0;
  first=groups[--g];
  do{buf[b++]=(char)('0'+first%10);first/=10;}while(first);
  while(b)digits[nd++]=(unsigned char)buf[--b];
  while(g){
   uint32_t x=groups[--g];
   for(i=0;i<9;i++){digits[nd+8-i]=(unsigned char)('0'+x%10);x/=10;}
   nd+=9;
  }
 }
 /* assemble: [sign] intpart [. fraction] */
 pos=0;
 {
  unsigned intlen=nd>dec?nd-dec:1;
  unsigned total=intlen+(dec?1+dec:0)+neg;
  if(total>cap)return 0;
  if(neg)out[pos++]='-';
  if(nd>dec){for(j=0;j<intlen;j++)out[pos++]=digits[j];}
  else out[pos++]='0';
  if(dec){
   unsigned fracdigits=nd>dec?dec:nd;
   unsigned lead=dec-fracdigits;
   out[pos++]='.';
   for(j=0;j<lead;j++)out[pos++]='0';
   for(j=0;j<fracdigits;j++)out[pos++]=digits[nd-fracdigits+j];
  }
 }
 return pos;
}

/* ---- Harbour N-field double formatter ---------------------------------
 * Harbour semantics, measured on official Harbour 3.2 (oracle probe of 26
 * values x 5 field shapes, tests/dbf/write-corpus/probe):
 *  1. the double first becomes its decimal string at 16 significant
 *     digits (Harbour's hb_dbl2string model), trailing zeros stripped;
 *  2. that DECIMAL is rounded half away from zero at the field decimals
 *     (2.685->2.69, 0.125->0.13, 15.5555->15.56, 0.045->0.05 - glibc
 *     "%.*f" on the exact binary value gives 2.68/0.12/15.55/0.04);
 *  3. a zero result drops the sign (-0.001 at dec 2 -> "0.00", and
 *     -0.0 -> "0.00").
 * Exact integer math: M = round(|value| * 10^340) as a bignum gives the
 * full exact decimal; the leading 16 digits (half-even at the 16th, ties
 * there are not representable in practice) feed step 2. Returns the byte
 * length, or 0 for inf/nan or insufficient cap (never writes then). */
unsigned hrdbf_fmt_harbour(unsigned char *out, unsigned cap, double value,
                           unsigned dec){
 union { double d; uint64_t u; } v;uint64_t m;int e2;long shift;
 hrbn a;uint32_t groups[80];unsigned ng=0,neg,i,j,pos;
 unsigned char digits[720];unsigned nd=0;int E;long cut;
 if(dec>32)return 0;
 v.d=value;
 neg=(unsigned)(v.u>>63);
 if(((v.u>>52)&0x7ff)==0x7ff)return 0; /* inf/nan: unencodable */
 if(!((v.u>>52)&0x7ff)){e2=-1074;m=v.u&0xfffffffffffffu;}
 else{e2=(int)((v.u>>52)&0x7ff)-1075;m=(v.u&0xfffffffffffffu)|0x10000000000000u;}
 if(!m){ /* zero: no sign, exact zeros */
  pos=0;if(pos+1+(dec?1+dec:0)>cap)return 0;
  out[pos++]='0';if(dec){out[pos++]='.';for(i=0;i<dec;i++)out[pos++]='0';}
  return pos;
 }
 /* M = round(m * 5^340 * 2^(e2+340)) = |value| * 10^340 */
 bn_set64(&a,m);
 for(i=0;i<340;i++)bn_mul32(&a,5);
 shift=(long)e2+340;
 if(shift>=0)bn_shl(&a,(unsigned)shift);
 else{
  unsigned cls=bn_shr_round(&a,(unsigned)-shift);
  if(cls>=2)bn_inc(&a);
 }
 while(!(a.n==1&&!a.w[0])&&ng<80)groups[ng++]=bn_divmod_1e9(&a);
 if(!ng){ /* |value| below 1e-341: zero at any admissible dec */
  pos=0;if(pos+1+(dec?1+dec:0)>cap)return 0;
  out[pos++]='0';if(dec){out[pos++]='.';for(i=0;i<dec;i++)out[pos++]='0';}
  return pos;
 }
 {
  unsigned g=ng;uint32_t first;char buf[10];unsigned b=0;
  first=groups[--g];
  do{buf[b++]=(char)('0'+first%10);first/=10;}while(first);
  while(b)digits[nd++]=(unsigned char)buf[--b];
  while(g){
   uint32_t x=groups[--g];
   for(i=0;i<9;i++){digits[nd+8-i]=(unsigned char)('0'+x%10);x/=10;}
   nd+=9;
  }
 }
 /* |value| = digits[0].digits[1..] x 10^E */
 E=(int)nd-341;
 /* Harbour converts through the SHORTEST decimal that round-trips to the
  * same double (9.995 is the double 9.994999999999999218... and Harbour
  * stores 10.00 at dec 2, not 9.99). Exact boundaries on the 10^340 grid:
  * Vm < candidate <= Vp (both accepted on a tie when the mantissa is even;
  * IEEE round-to-nearest-even). Vp/Vm need the same scale as M. */
 {
  hrbn vp,vm;unsigned pdigits;
  bn_set64(&vp,2*m+1);for(i=0;i<340;i++)bn_mul32(&vp,5);
  bn_shl(&vp,(unsigned)(e2+339));
  if(e2!=-1074&&m==0x10000000000000u){ /* power of two: lower gap is half */
   bn_set64(&vm,4*m-1);for(i=0;i<340;i++)bn_mul32(&vm,5);
   bn_shl(&vm,(unsigned)(e2+338));
  }else{
   bn_set64(&vm,2*m-1);for(i=0;i<340;i++)bn_mul32(&vm,5);
   bn_shl(&vm,(unsigned)(e2+339));
  }
  /* shortest p-digit rounding of the exact decimal that stays in [vm,vp] */
  for(pdigits=1;pdigits<=17&&pdigits<nd;pdigits++){
   uint64_t cand=0;long ce;hrbn cb;int c1,c2;unsigned up;
   for(i=0;i<pdigits;i++)cand=cand*10+(uint64_t)(digits[i]-'0');
   up=digits[pdigits]>'5'||(digits[pdigits]=='5'&&(cand&1u));
   if(!up&&digits[pdigits]=='5'){for(i=pdigits+1;i<nd;i++)if(digits[i]!='0'){up=1;break;}}
   if(up)cand++;
   ce=(long)E-(long)pdigits+341; /* candidate x 10^(ce-340) on the grid */
   /* rounding carry may add a digit: 99.9->100 at p=2 keeps p digits with
    * exponent+1; cand==10^p then: divide by 10 and bump E handled below */
   if(cand>=10){uint64_t t=cand,pp=1;unsigned dg=1;while(t>=10){t/=10;pp*=10;dg++;}
    if(dg>pdigits){cand/=10;ce++;}}
   bn_set64(&cb,cand);for(i=0;i<(unsigned)ce;i++)bn_mul32(&cb,5);
   bn_shl(&cb,(unsigned)ce);
   c1=bn_cmp(&cb,&vm);c2=bn_cmp(&cb,&vp);
   if(c1>0&&c2<0)goto found;
   if((c1==0||c2==0)&&!(m&1u))goto found;
  }
  pdigits=nd>17?17:nd; /* unreachable: the exact digits always round-trip */
found:
  /* rebuild the digit string from the winning candidate */
  {
   uint64_t cand=0;unsigned up;
   for(i=0;i<pdigits;i++)cand=cand*10+(uint64_t)(digits[i]-'0');
   if(pdigits<nd){up=digits[pdigits]>'5'||(digits[pdigits]=='5'&&(cand&1u));
    if(!up&&digits[pdigits]=='5'){for(i=pdigits+1;i<nd;i++)if(digits[i]!='0'){up=1;break;}}
    if(up)cand++;}
   {
    char tb[20];unsigned b=0;
    do{tb[b++]=(char)('0'+cand%10);cand/=10;}while(cand);
    if(b>pdigits){b--;E++;} /* rounding carry: 99.9->100 keeps p digits */
    nd=b;for(i=0;i<b;i++)digits[i]=(unsigned char)tb[b-1-i];
   }
  }
 }
 /* strip trailing zeros */
 while(nd>1&&digits[nd-1]=='0')nd--;
 /* step 2: round the decimal half away from zero at dec decimals */
 cut=1+(long)E+(long)dec; /* digits to keep, counting from digits[0] */
 if(cut<=0){
  if(cut==0&&digits[0]>='5'){digits[0]='1';nd=1;E=-(int)dec;}
  else{nd=1;digits[0]='0';E=0;neg=0;}
 }else if(cut<(long)nd){
  unsigned up=digits[cut]>='5';
  nd=(unsigned)cut;
  if(up){i=nd;while(i-- >0){if(digits[i]!='9'){digits[i]++;break;}digits[i]='0';}
   if(i==(unsigned)-1){digits[0]='1';E++;}}
  while(nd>1&&digits[nd-1]=='0')nd--;
 }
 if(nd==1&&digits[0]=='0')neg=0; /* zero result drops the sign */
 /* render: value = digits[0].digits[1..nd-1] x 10^E */
 pos=0;
 {
  long intlen=E>=0?(long)E+1:1;
  long total=intlen+(dec?1+(long)dec:0)+(neg?1:0);
  if(total>(long)cap||total>400)return 0;
  if(neg)out[pos++]='-';
  if(E>=0){for(j=0;j<=(unsigned)E;j++)out[pos++]=j<nd?digits[j]:(unsigned char)'0';}
  else out[pos++]='0';
  if(dec){
   out[pos++]='.';
   for(j=0;j<dec;j++){long idx=(long)E+1+j;out[pos++]=(idx>=0&&(unsigned)idx<nd)?digits[idx]:(unsigned char)'0';}
  }
 }
 return pos;
}

/* ---- shared field-slice helpers --------------------------------------- */
static void fill(unsigned char *dst,unsigned n,unsigned char c){
 unsigned i;for(i=0;i<n;i++)dst[i]=c;
}
/* Right-align a formatted number into the field slice; '*' fill when the
 * value overflows the declared width (xBase overflow convention, matching
 * hrv_render). */
static hrdbf_error put_number(unsigned char *rec, const hrdbf_field *f,
                              const unsigned char *num, unsigned len){
 unsigned char *dst=rec+f->offset;unsigned pad,i;
 if(f->type!='N')return HRDBF_TYPE;
 if(len>(unsigned)f->width){fill(dst,f->width,'*');return HRDBF_OK;}
 pad=(unsigned)f->width-len;
 fill(dst,pad,' ');
 for(i=0;i<len;i++)dst[pad+i]=num[i];
 return HRDBF_OK;
}

/* ---- public encoders --------------------------------------------------- */
hrdbf_error hrdbf_write_char(unsigned char *rec, const hrdbf_field *f,
                             const unsigned char *text, size_t len){
 unsigned char *dst=rec+f->offset;size_t n,i;
 if(f->type!='C')return HRDBF_TYPE;
 n=len<(size_t)f->width?len:(size_t)f->width;
 for(i=0;i<n;i++)dst[i]=text[i];
 for(i=n;i<(size_t)f->width;i++)dst[i]=' ';
 return HRDBF_OK;
}

hrdbf_error hrdbf_write_number_scaled(unsigned char *rec, const hrdbf_field *f,
                                      int64_t scaled, unsigned decimals){
 unsigned char num[64],digits[40];unsigned nd=0,pos=0,i,neg=0;
 uint64_t mag,div=1;
 if(f->type!='N')return HRDBF_TYPE;
 if(f->decimals>17||f->decimals>=f->width)return HRDBF_LIMIT;
 if(decimals>17)return HRDBF_LIMIT;
 if(scaled<0){neg=1;mag=(uint64_t)(-(scaled+1))+1;}
 else mag=(uint64_t)scaled;
 if(decimals>f->decimals){
  unsigned d=decimals-f->decimals;uint64_t rem;
  for(i=0;i<d;i++)div*=10;
  rem=mag%div;mag/=div;
  /* Harbour rounds the decimal representation half away from zero
   * (oracle corpus2: 2.685->2.69, 0.125->0.13, -2.675->-2.68, 2.5->3). */
  if(rem>div/2||(rem==div/2))mag++;
 }else if(decimals<f->decimals){
  unsigned d=f->decimals-decimals;
  /* Freestanding: 64-bit only. Overflow means the coefficient cannot fit
   * any admissible field width; render as width overflow (stars). */
  for(i=0;i<d;i++){if(mag>UINT64_MAX/10){fill(rec+f->offset,f->width,'*');return HRDBF_OK;}mag*=10;}
 }
 {
  uint64_t t=mag;
  do{digits[nd++]=(unsigned char)('0'+t%10);t/=10;}while(t);
 }
 {
  unsigned intlen=nd>f->decimals?nd-f->decimals:1;
  unsigned total=intlen+(f->decimals?1+f->decimals:0)+neg;
  if(total>(unsigned)f->width){fill(rec+f->offset,f->width,'*');return HRDBF_OK;}
  if(neg)num[pos++]='-';
  if(nd>f->decimals){for(i=0;i<intlen;i++)num[pos++]=digits[nd-1-i];}
  else num[pos++]='0';
  if(f->decimals){
   unsigned fracdigits=nd>f->decimals?f->decimals:nd;
   unsigned lead=f->decimals-fracdigits;
   num[pos++]='.';
   for(i=0;i<lead;i++)num[pos++]='0';
   for(i=0;i<fracdigits;i++)num[pos++]=digits[fracdigits-1-i];
  }
 }
 return put_number(rec,f,num,pos);
}

hrdbf_error hrdbf_write_number_double(unsigned char *rec, const hrdbf_field *f,
                                      double value){
 unsigned char num[400];unsigned len;
 if(f->type!='N')return HRDBF_TYPE;
 if(f->decimals>17||f->decimals>=f->width)return HRDBF_LIMIT;
 len=hrdbf_fmt_harbour(num,sizeof num,value,f->decimals);
 if(!len)return HRDBF_DATA; /* inf/nan unencodable */
 return put_number(rec,f,num,len);
}

hrdbf_error hrdbf_write_date(unsigned char *rec, const hrdbf_field *f,
                             uint32_t yyyymmdd){

 unsigned char *dst=rec+f->offset;
 unsigned y,m,d,max;
 if(f->type!='D')return HRDBF_TYPE;
 if(!yyyymmdd){fill(dst,8,' ');return HRDBF_OK;}
 y=yyyymmdd/10000;m=yyyymmdd/100%100;d=yyyymmdd%100;
 if(!y||m<1||m>12||!d)return HRDBF_DATA;
 /* Arithmetic month length: a static table aliases the codec's identical
  * array into a .set pair the internal assembler cannot read. */
 max=(m==2)?28:((m==4||m==6||m==9||m==11)?30:31);
 if(m==2&&y%4==0&&(y%100!=0||y%400==0))max++;
 if(d>max)return HRDBF_DATA;
 dst[0]=(unsigned char)('0'+y/1000%10);dst[1]=(unsigned char)('0'+y/100%10);
 dst[2]=(unsigned char)('0'+y/10%10);dst[3]=(unsigned char)('0'+y%10);
 dst[4]=(unsigned char)('0'+m/10);dst[5]=(unsigned char)('0'+m%10);
 dst[6]=(unsigned char)('0'+d/10);dst[7]=(unsigned char)('0'+d%10);
 return HRDBF_OK;
}

hrdbf_error hrdbf_write_logical(unsigned char *rec, const hrdbf_field *f,
                                unsigned char value){
 unsigned char *dst=rec+f->offset;
 if(f->type!='L')return HRDBF_TYPE;
 *dst=value?'T':'F';
 return HRDBF_OK;
}

hrdbf_error hrdbf_write_blank(unsigned char *rec, const hrdbf_field *f){
 unsigned char *dst=rec+f->offset;
 if(f->type!='C'&&f->type!='N'&&f->type!='D'&&f->type!='L')return HRDBF_TYPE;
 fill(dst,f->width,' ');
 return HRDBF_OK;
}

void hrdbf_write_deleted(unsigned char *rec, unsigned char deleted){
 rec[0]=deleted?'*':' ';
}
