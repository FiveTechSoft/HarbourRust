/* Own MIT. Timestamp scalar: Julian day in high 32 bits, milliseconds since
 * midnight in low 32 bits. Empty day is zero; time-only values are preserved.
 * This is our representation, not a Harbour item or imported VM code. */
typedef unsigned long long u64;
extern u64 hbc_stod(const char *,u64);
extern u64 hbc_date_days(u64);
extern u64 hbc_date_from_days(u64);
extern u64 hbc_date_core_c(u64,char *);
extern void *hbc_alloc(u64);
struct txt {char *p;u64 n;};
static u64 day(u64 d){return d?hbc_date_days(d)+2440588ULL:0;}
static u64 date(u64 t){u64 d=t>>32;return d?hbc_date_from_days(d-2440588ULL):0;}
static u64 digits(const char *p,u64 n){u64 x=0;while(n--)x=x*10+(unsigned)(*p++-'0');return x;}
static void put(char *p,u64 x,u64 n){while(n){p[--n]=(char)('0'+x%10);x/=10;}}
static struct txt text(u64 n){struct txt s;u64 *p=hbc_alloc(n+16);p[0]=n;p[1]=n;s.p=(char *)(p+2);s.n=n;return s;}
u64 hbc_ts_parse(const char *p,u64 len){
 u64 n=0,d=0,h=0,m=0,s=0,ms=0,k;
 while(n<len && p[n]>='0' && p[n]<='9')n++;
 if(n==8 || n>=10){d=hbc_stod(p,8);p+=8;n-=8;}
 if(n==2 || n==4 || n>=6){
  h=digits(p,2);if(n>=4)m=digits(p+2,2);if(n>=6)s=digits(p+4,2);
  k=n>6?n-6:0;if(k>3)k=3;if(k){ms=digits(p+6,k);while(k++<3)ms*=10;}
  if(h>23 || m>59 || s>59)h=m=s=ms=0;
 }
 return (day(d)<<32)|(h*3600000+m*60000+s*1000+ms);
}
u64 hbc_ts_from_date(u64 d){return day(d)<<32;}
u64 hbc_ts_to_date(u64 t){return date(t);}
u64 hbc_ts_midnight(u64 t){return t&0xffffffff00000000ULL;}
struct txt hbc_ts_string(u64 t){
 struct txt out=text(17);u64 d=date(t),ms=(unsigned)t;
 put(out.p,d,8);put(out.p+8,ms/3600000,2);put(out.p+10,ms/60000%60,2);
 put(out.p+12,ms/1000%60,2);put(out.p+14,ms%1000,3);return out;
}
u64 hbc_ts_render(u64 t,char *out){
 u64 n=hbc_date_core_c(date(t),out),ms=(unsigned)t;
 out[n++]=' ';put(out+n,ms/3600000,2);n+=2;out[n++]=':';
 put(out+n,ms/60000%60,2);n+=2;out[n++]=':';put(out+n,ms/1000%60,2);n+=2;
 out[n++]='.';put(out+n,ms%1000,3);return n+3;
}

/* Own format subset, verified through black-box oracle fixtures. Mask syntax
 * is checked by the compiler; there is no locale token interpretation here. */
static char upper(char c){return c>='a'&&c<='z'?(char)(c-32):c;}
static u64 mask_date(u64 d,const char *f,u64 n,char *p){
 u64 i=0,j,k,v;
 while(i<n){char c=upper(f[i]);j=i+1;while(j<n&&upper(f[j])==c)j++;k=j-i;
  if(c=='Y'||c=='M'||c=='D'){
   v=c=='Y'?d/10000:(c=='M'?d/100%100:d%100);
   if(d)put(p+i,v,k);else{u64 z;for(z=i;z<j;z++)p[z]=' ';}
  }else{u64 z;for(z=i;z<j;z++)p[z]=upper(f[z]);}i=j;
 }return n;
}
static u64 mask_time(u64 ms,const char *f,u64 n,char *p){
 u64 i=0,j,k,v;
 while(i<n){char c=upper(f[i]);j=i+1;while(j<n&&upper(f[j])==c)j++;k=j-i;
  if(c=='H'||c=='M'||c=='S'||c=='F'){
   v=c=='H'?ms/3600000:(c=='M'?ms/60000%60:(c=='S'?ms/1000%60:ms%1000));put(p+i,v,k);
  }else{u64 z;for(z=i;z<j;z++)p[z]=upper(f[z]);}i=j;
 }return n;
}
struct txt hbc_ts_format(u64 t,const char *df,u64 dn,const char *tf,u64 tn,u64 flags){
 char buf[560];u64 n=0,i,d=date(t),ms=(unsigned)t;struct txt o;
 if(flags&1)n=hbc_date_core_c(d,buf);else n=mask_date(d,df,dn,buf);
 if(!(flags&4)){
  if((flags&1)||dn)buf[n++]=' ';
  if(flags&2){put(buf+n,ms/3600000,2);n+=2;buf[n++]=':';put(buf+n,ms/60000%60,2);n+=2;buf[n++]=':';put(buf+n,ms/1000%60,2);n+=2;buf[n++]='.';put(buf+n,ms%1000,3);n+=3;}
  else n+=mask_time(ms,tf,tn,buf+n);
 }
 o=text(n);for(i=0;i<n;i++)o.p[i]=buf[i];return o;
}
/* Returns 2 for an unsupported kind, otherwise Harbour scalar Empty. */
u64 hbc_ts_empty(u64 tag,u64 payload){
 u64 i,n;const char *p;union {u64 u;double d;} x;
 if((tag&255)==5){if(tag>>63)x.d=*(const double *)payload;else x.u=payload;return x.d==0.0;}
 if(tag==1)return 1;
 if(tag==0||tag==9||tag==3||tag==11||tag==17)return payload==0;
 if(tag==2||tag==4){p=(const char *)payload;n=((const u64 *)p)[-1];for(i=0;i<n;i++)if(p[i]!=' '&&p[i]!='\t'&&p[i]!='\n'&&p[i]!='\r')return 0;return 1;}
 return 2;
}

/* Bounded literal component constructor, measured against Harbour. */
u64 hbc_ts_construct(const long long *v){
 char str[8];u64 d=0,ms=0;
 if(v[0]>=1&&v[0]<=9999&&v[1]>=1&&v[1]<=12&&v[2]>=1&&v[2]<=31){
  put(str,(u64)v[0],4);put(str+4,(u64)v[1],2);put(str+6,(u64)v[2],2);d=hbc_stod(str,8);
 }
 if(v[3]>=0&&v[3]<24&&v[4]>=0&&v[4]<60&&v[5]>=0&&v[5]<60&&v[6]>=0&&v[6]<1000)ms=(u64)v[3]*3600000+(u64)v[4]*60000+(u64)v[5]*1000+(u64)v[6];
 return (day(d)<<32)|ms;
}
