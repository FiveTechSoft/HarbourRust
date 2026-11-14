/* Own MIT. No libc or allocation. Scalar tags11/12 keep the16-byte ABI. */
#include "hrvalue.h"
hrv_cell hrv_date(uint32_t p){hrv_cell v={HRV_DATE,p};return v;}
hrv_cell hrv_number(int64_t p,unsigned width,unsigned decimals){hrv_cell v={HRV_FIELD_NUMERIC|((uint64_t)decimals<<8)|((uint64_t)width<<16),(uint64_t)p};return v;}
hrv_error hrv_validate(hrv_cell v){
 unsigned k=hrv_kind(v);
 if(k>HRV_FIELD_NUMERIC)return HRV_TAG_INVALID;
 if(k==HRV_FIELD_NUMERIC){if(v.tag>>32||!hrv_width(v)||hrv_width(v)>255||hrv_decimals(v)>17||hrv_decimals(v)>=hrv_width(v))return HRV_TAG_INVALID;}
 else if(k!=HRV_DOUBLE&&v.tag>>8)return HRV_TAG_INVALID;
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
 e=hrv_i64(a,&na);if(e)return e;e=hrv_i64(b,&nb);if(e)return e;*out=na==nb;return HRV_OK;
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
const char *hrv_error_name(hrv_error e){switch(e){case HRV_OK:return "ok";case HRV_TYPE:return "DBF value type outside admitted operation";case HRV_DECIMAL_I64:return "DBF decimal numeric cannot enter I64 operation";case HRV_BUFFER:return "DBF value output buffer too short";case HRV_TAG_INVALID:return "DBF value tag or metadata invalid";}return "DBF unknown value error";}
