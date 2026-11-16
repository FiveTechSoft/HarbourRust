#include "hrdyn.h"
/* Own MIT. No libc or allocation. Scalar tags11/12 keep the16-byte ABI. */
#include "hrvalue.h"
static hrv_error hrv_to_double(hrv_cell,double *,unsigned *);
hrv_cell hrv_date(uint32_t p){hrv_cell v={HRV_DATE,p};return v;}
hrv_cell hrv_number(int64_t p,unsigned width,unsigned decimals){hrv_cell v={HRV_FIELD_NUMERIC|((uint64_t)decimals<<8)|((uint64_t)width<<16),(uint64_t)p};return v;}
hrv_error hrv_validate(hrv_cell v){
 unsigned k=hrv_kind(v);
 if(k>HRV_FIELD_NUMERIC)return HRV_TAG_INVALID;
 if(k==HRV_FIELD_NUMERIC){if(v.tag>>32||!hrv_width(v)||hrv_width(v)>255||hrv_decimals(v)>17||hrv_decimals(v)>=hrv_width(v))return HRV_TAG_INVALID;}
 else if(k!=HRV_DOUBLE&&v.tag>>8)return HRV_TAG_INVALID;
 else if(k==HRV_DOUBLE&&(v.tag&HR_DYN_FLOAT_HEAP)&&v.tag!=(HR_DYN_FLOAT_HEAP|HRV_DOUBLE))return HRV_TAG_INVALID;
 if(k==HRV_DATE){if(v.payload>99991231u)return HRV_TAG_INVALID;unsigned y=(unsigned)(v.payload/10000),m=(unsigned)(v.payload/100%100),d=(unsigned)(v.payload%100),limit;static const unsigned days[]={31,28,31,30,31,30,31,31,30,31,30,31};
 if(!v.payload)return HRV_OK;if(y<1||y>9999||m<1||m>12||d<1)return HRV_TAG_INVALID;
 limit=days[m-1]+(m==2&&y%4==0&&(y%100!=0||y%400==0));if(d>limit)return HRV_TAG_INVALID;}
 return HRV_OK;
}
char hrv_valtype(hrv_cell v){
 switch(hrv_kind(v)){
 case HRV_I64:case HRV_I64_LITERAL:case HRV_DOUBLE:case HRV_FIELD_NUMERIC:return 'N';
 case HRV_NIL:return 'U';case HRV_STR_BORROW:case HRV_STR_OWN:return 'C';
 case HRV_LOGICAL:return 'L';case HRV_SUBARRAY:case HRV_ARRAY:return 'A';
 case HRV_BLOCK:return 'B';case HRV_DATE:return 'D';default:return '?';}
}
hrv_error hrv_i64(hrv_cell v,int64_t *out){
 unsigned k=hrv_kind(v);hrv_error e=hrv_validate(v);if(e)return e;
 if(k==HRV_FIELD_NUMERIC){if(hrv_decimals(v))return HRV_DECIMAL_I64;}
 else if(k!=HRV_I64&&k!=HRV_I64_LITERAL)return HRV_TYPE;
 *out=(int64_t)v.payload;return HRV_OK;
}
hrv_error hrv_equal(hrv_cell a,hrv_cell b,int *out){
 unsigned ka=hrv_kind(a),kb=hrv_kind(b);int64_t na,nb;hrv_error e=hrv_validate(a);if(e)return e;e=hrv_validate(b);if(e)return e;
 if(ka==HRV_DATE&&kb==HRV_DATE){*out=a.payload==b.payload;return HRV_OK;}
 if(ka==HRV_NIL||kb==HRV_NIL){*out=ka==kb;return HRV_OK;}
 if(ka==HRV_LOGICAL&&kb==HRV_LOGICAL){*out=!!a.payload==!!b.payload;return HRV_OK;}
 /* D4: numerics compare BY VALUE (Harbour hb_vmEqual measured: SALDO =
 * 1000.050 is .T. though the decimals differ). Fast path i64 x i64 is
 * integer-exact; otherwise both widen to double (field N: payload/10^dec,
 * matching the ASCII read). A numeric against a non-numeric stays the
 * typed failure (Harbour's BASE/1071 dialog is the registered
 * failure-mode difference). IEEE rule: NaN compares unequal. */
 if(hrv_i64(a,&na)==HRV_OK&&hrv_i64(b,&nb)==HRV_OK){*out=na==nb;return HRV_OK;}
 {double da,db;unsigned ca,cb;
  if(hrv_to_double(a,&da,&ca)==HRV_OK&&hrv_to_double(b,&db,&cb)==HRV_OK){*out=da==db;return HRV_OK;}}
 return HRV_TYPE;
}
hrv_error hrv_compare(hrv_cell a,hrv_cell b,int64_t *out){
 int64_t na,nb;hrv_error e=hrv_validate(a);if(e)return e;e=hrv_validate(b);if(e)return e;
 if(hrv_i64(a,&na)==HRV_OK&&hrv_i64(b,&nb)==HRV_OK){*out=na<nb?-1:na>nb;return HRV_OK;}
 {double da,db;unsigned ca,cb;
  if(hrv_to_double(a,&da,&ca)==HRV_OK&&hrv_to_double(b,&db,&cb)==HRV_OK){*out=da<db?-1:da>db?1:0;return HRV_OK;}}
 return HRV_TYPE;
}
hrv_error hrv_empty(hrv_cell v,int *out){
 hrv_error e=hrv_validate(v);if(e)return e;
 switch(hrv_kind(v)){
 case HRV_NIL:*out=1;return HRV_OK;
 case HRV_I64:case HRV_I64_LITERAL:case HRV_FIELD_NUMERIC:case HRV_DATE:case HRV_LOGICAL:*out=v.payload==0;return HRV_OK;
 default:return HRV_TYPE;}
}
hrv_error hrv_render(hrv_cell v,unsigned char *out,size_t cap,size_t *len){
 unsigned k=hrv_kind(v),i,w,d;unsigned char digits[20];unsigned n=0,total,pad,integer;uint64_t magnitude;int64_t signedval;hrv_error e=hrv_validate(v);if(e)return e;
 if(k==HRV_DATE){unsigned y,m,day;if(cap<8)return HRV_BUFFER;*len=8;
 if(!v.payload){for(i=0;i<8;i++)out[i]=(i==2||i==5)?'/':' ';return HRV_OK;}
 y=(unsigned)(v.payload/10000);m=(unsigned)(v.payload/100%100);day=(unsigned)(v.payload%100);
 out[0]='0'+m/10;out[1]='0'+m%10;out[2]='/';out[3]='0'+day/10;out[4]='0'+day%10;out[5]='/';out[6]='0'+y/10%10;out[7]='0'+y%10;return HRV_OK;}
 if(k!=HRV_FIELD_NUMERIC)return HRV_TYPE;
 w=hrv_width(v);d=hrv_decimals(v);signedval=(int64_t)v.payload;
 magnitude=signedval<0?(uint64_t)(-(signedval+1))+1:(uint64_t)signedval;
 do{digits[n++]=(unsigned char)('0'+magnitude%10);magnitude/=10;}while(magnitude);
 integer=n>d?n-d:1;total=integer+(d?1+d:0)+(signedval<0);
 if(cap<w)return HRV_BUFFER;*len=w;
 /* Field width is fixed. Overflow is not silently widened or truncated. */
 if(total>w){for(i=0;i<w;i++)out[i]='*';return HRV_OK;}
 pad=w-total;for(i=0;i<pad;i++)out[i]=' ';
 if(signedval<0)out[pad++]='-';
 for(i=0;i<integer;i++){unsigned index=d+integer-1-i;out[pad++]=index<n?digits[index]:'0';}
 if(d){out[pad++]='.';for(i=0;i<d;i++){unsigned index=d-1-i;out[pad++]=index<n?digits[index]:'0';}}
 return HRV_OK;
}
/* D3: numeric cell -> (double, dec). Field numerics carry the scaled
 * integer, so value = payload / 10^dec (correctly rounded, matching the
 * ASCII read); legacy inline floats take their bits and the tag dec with
 * the established 0-means-2 convention; heap floats read the owned item. */
static hrv_error hrv_to_double(hrv_cell v,double *out,unsigned *dec){
 unsigned k=hrv_kind(v);int64_t n;double d;unsigned c,i;
 if(k==HRV_I64||k==HRV_I64_LITERAL){*out=(double)(int64_t)v.payload;*dec=0;return HRV_OK;}
 if(k==HRV_FIELD_NUMERIC){c=hrv_decimals(v);n=(int64_t)v.payload;d=(double)n;for(i=0;i<c;i++)d/=10.0;*out=d;*dec=c;return HRV_OK;}
 if(k==HRV_DOUBLE){union{uint64_t u;double d;}b;
  if(v.tag&HR_DYN_FLOAT_HEAP){const uint64_t *p=(const uint64_t *)v.payload;b.u=p[0];c=(unsigned)(p[1]&0xffff);}
  else{b.u=v.payload;c=(unsigned)(v.tag>>8);if(!c)c=2;}
  *out=b.d;*dec=c;return HRV_OK;}
 return HRV_TYPE;
}
/* D5: fmod via x87 FPREM (exact partial remainder loop, sign of the
 * dividend, same algorithm as the compiler's published hrm_fmod) and
 * pow via the hrm_powf core (2^(y*log2 x): FYL2X, F2XM1 + FSCALE).
 * Inline asm keeps the runtime freestanding (no libm). */
static double hrv_fmod87(double x,double y){
 double r;
 __asm__ volatile("fldl %2\n\tfldl %1\n\t1: fprem\n\tfnstsw %%ax\n\ttest $4,%%ah\n\tjnz 1b\n\tfstpl %0\n\tfstp %%st(0)"
  :"=m"(r):"m"(x),"m"(y):"ax","st","st(1)");
 return r;
}
static double hrv_pow87(double x,double y){
 double r;
 __asm__ volatile("fldl %2\n\tfldl %1\n\tfyl2x\n\tfld %%st(0)\n\tfrndint\n\tfxch %%st(1)\n\tfsub %%st(1),%%st(0)\n\tf2xm1\n\tfld1\n\tfaddp %%st(0),%%st(1)\n\tfscale\n\tfstp %%st(1)\n\tfstpl %0"
  :"=m"(r):"m"(x),"m"(y):"st","st(1)");
 return r;
}
hrv_error hrv_arith(unsigned op,hrv_cell a,hrv_cell b,hrv_cell *out){
 hrv_error e=hrv_validate(a);if(e)return e;e=hrv_validate(b);if(e)return e;
 if(op=='+'||op=='-'||op=='*'){
  int64_t na,nb;
  if(hrv_i64(a,&na)==HRV_OK&&hrv_i64(b,&nb)==HRV_OK){
   /* Unsigned arithmetic: defined two's-complement wrap, mirroring the
    * compiler's emitted add/sub/imul (and Harbour's wrapping LONGs). */
   out->tag=HRV_I64;
   if(op=='+')out->payload=(uint64_t)na+(uint64_t)nb;
   else if(op=='-')out->payload=(uint64_t)na-(uint64_t)nb;
   else out->payload=(uint64_t)na*(uint64_t)nb;
   return HRV_OK;
  }
 }
 if(op=='+'||op=='-'||op=='*'||op=='/'){
  double da,db,r;unsigned ca,cb,dec;union{double d;uint64_t u;}bits;
  e=hrv_to_double(a,&da,&ca);if(e)return e;
  e=hrv_to_double(b,&db,&cb);if(e)return e;
  if(op=='+'){r=da+db;dec=ca>cb?ca:cb;}
  else if(op=='-'){r=da-db;dec=ca>cb?ca:cb;}
  else if(op=='*'){r=da*db;dec=ca+cb;if(dec>255)dec=255;}
  else{if(db==0.0)return HRV_ZERODIV;r=da/db;dec=2;}
  bits.d=r;out->tag=HRV_DOUBLE|((uint64_t)dec<<8);out->payload=bits.u;
  return HRV_OK;
 }
 if(op=='%'||op=='^'){
  double da,db,r;unsigned ca,cb;union{double d;uint64_t u;}bits;
  e=hrv_to_double(a,&da,&ca);if(e)return e;
  e=hrv_to_double(b,&db,&cb);if(e)return e;
  if(op=='%'){
   /* hb_vmModulus: C fmod, sign of the DIVIDEND (test7 oracle:
    * -1000.05%3 = -1.05, 1000.05%-3 = 1.05); the result is ALWAYS a
    * double with dec = SET DECIMALS (2) - even for integer operands
    * (hk348, oracle: LIMITE%7 prints 5.00). A zero divisor yields the
    * integer-image 0 (hk343/hk344, oracle: `x % 0` prints 0). */
   if(db==0.0){out->tag=HRV_I64;out->payload=0;return HRV_OK;}
   r=hrv_fmod87(da,db);
  }else{
   /* hb_vmPower: C pow (test7 oracle: 1000.05^2 = 1000100.00 with the
    * glibc rounding, ^0 = 1.00, ^1 = 1000.05, always dec = SET(2)).
    * glibc edge arms measured: base < 0 with an INTEGRAL exponent is
    * exact (pow(-2,3) = -8.00); fractional exponent of a negative base
    * is NaN (t809 prints it as asterisks, like the static path); 0^0 =
    * 1; 0^negative = +Inf (Harbour's recoverable dialog stays the
    * registered failure-mode difference). Doubles >= 2^53 are always
    * integral; their parity is undecidable, treated even (same as the
    * published static helper). */
   {
    /* Ordered double compares go through BIT manipulation (union
     * uint64): the internal assembler does not take cmpltsd. For
     * positive doubles the IEEE bit pattern orders like the value;
     * sign/magnitude extraction and negation are xor/and on bits. */
    union{double d;uint64_t u;}ba,bb,be,t;
    uint64_t maga,magb;double ae;
    ba.d=da;bb.d=db;maga=ba.u&0x7FFFFFFFFFFFFFFFULL;magb=bb.u&0x7FFFFFFFFFFFFFFFULL;
    if((ba.u>>63)!=0&&maga!=0){
     /* base < 0 (a real negative; -0.0 falls to the zero arm below) */
     be.u=magb;ae=be.d;
     if(magb>=0x4330000000000000ULL||ae==(double)(int64_t)ae){
      t.u=maga;r=hrv_pow87(t.d,db);
      if(magb<0x4330000000000000ULL&&(((int64_t)ae)&1))r=0.0-r; /* exact sign flip: subsd, no btcq/mask constants */
     }else{bits.u=0x7FF8000000000000ULL;r=bits.d;}
    }else if(maga==0){
     /* base +-0: 0^0 = 1, 0^positive = +0, 0^negative = +Inf */
     if(magb==0)r=1.0;else if((bb.u>>63)==0)r=0.0;else{bits.u=0x7FF0000000000000ULL;r=bits.d;}
    }else r=hrv_pow87(da,db);
   }
  }
  bits.d=r;out->tag=HRV_DOUBLE|((uint64_t)2<<8);out->payload=bits.u;
  return HRV_OK;
 }
 return HRV_TYPE;
}
const char *hrv_error_name(hrv_error e){switch(e){case HRV_OK:return "ok";case HRV_TYPE:return "DBF value type outside admitted operation";case HRV_DECIMAL_I64:return "DBF decimal numeric cannot enter I64 operation";case HRV_BUFFER:return "DBF value output buffer too short";case HRV_TAG_INVALID:return "DBF value tag or metadata invalid";case HRV_ZERODIV:return "DBF arithmetic division by zero";}return "DBF unknown value error";}
