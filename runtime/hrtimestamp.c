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
