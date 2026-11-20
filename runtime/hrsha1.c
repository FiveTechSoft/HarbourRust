/* Original MIT implementation from the mathematical definitions in
 * FIPS 180-4 sections 4.1.1, 4.2.1, 5 and 6.1, and RFC 2104 section 2.
 * No code taken from Harbour, RFC sample code, or a third-party library.
 * Compatibility primitive, not a recommendation of SHA-1 for new designs.
 * SysV entry points, caller owns all memory. No OS or library calls.
 */
#include <stdint.h>
#include <stddef.h>
typedef struct { uint32_t state[5]; uint64_t bytes; unsigned fill; unsigned char block[64]; } hr_sha1_state;
static uint32_t turn(uint32_t x,unsigned n){return (x<<n)|(x>>(32-n));}
static void compress(hr_sha1_state *s){
 uint32_t w[80];
 for(unsigned i=0;i<16;i++){const unsigned char *p=s->block+4*i;w[i]=((uint32_t)p[0]<<24)|((uint32_t)p[1]<<16)|((uint32_t)p[2]<<8)|(uint32_t)p[3];}
 for(unsigned i=16;i<80;i++)w[i]=turn(w[i-3]^w[i-8]^w[i-14]^w[i-16],1);
 uint32_t a=s->state[0],b=s->state[1],c=s->state[2],d=s->state[3],e=s->state[4];
 for(unsigned i=0;i<80;i++){
  uint32_t f,k;
  if(i<20){f=(b&c)^((~b)&d);k=0x5a827999u;}
  else if(i<40){f=b^c^d;k=0x6ed9eba1u;}
  else if(i<60){f=(b&c)^(b&d)^(c&d);k=0x8f1bbcdcu;}
  else{f=b^c^d;k=0xca62c1d6u;}
  uint32_t next=turn(a,5)+f+e+k+w[i];e=d;d=c;c=turn(b,30);b=a;a=next;
 }
 s->state[0]+=a;s->state[1]+=b;s->state[2]+=c;s->state[3]+=d;s->state[4]+=e;
}
static void start(hr_sha1_state *s){
 s->state[0]=0x67452301u;s->state[1]=0xefcdab89u;s->state[2]=0x98badcfeu;s->state[3]=0x10325476u;s->state[4]=0xc3d2e1f0u;s->bytes=0;s->fill=0;
}
static void feed(hr_sha1_state *s,const unsigned char *p,size_t n){
 s->bytes+=(uint64_t)n;
 while(n){unsigned take=64-s->fill;if((size_t)take>n)take=(unsigned)n;
  for(unsigned i=0;i<take;i++)s->block[s->fill+i]=p[i];
  s->fill+=take;p+=take;n-=take;
  if(s->fill==64){compress(s);s->fill=0;}
 }
}
static void finish(hr_sha1_state *s,unsigned char *out){
 uint64_t bits=s->bytes*8u;unsigned char padding[64]={0x80};unsigned n=s->fill<56?56-s->fill:120-s->fill;
 feed(s,padding,n);
 unsigned char length[8];for(unsigned i=0;i<8;i++)length[i]=(unsigned char)(bits>>(56-8*i));feed(s,length,8);
 for(unsigned i=0;i<20;i++)out[i]=(unsigned char)(s->state[i/4]>>(24-8*(i%4)));
}
void hbc_sha1_digest(const unsigned char *p,size_t n,unsigned char *out){hr_sha1_state s;start(&s);feed(&s,p,n);finish(&s,out);}
void hbc_hmac_sha1_digest(const unsigned char *p,size_t n,const unsigned char *key,size_t keyn,unsigned char *out){
 unsigned char k[64]={0},pad[64],inner[20];
 if(keyn>64)hbc_sha1_digest(key,keyn,k);else for(size_t i=0;i<keyn;i++)k[i]=key[i];
 hr_sha1_state s;start(&s);for(unsigned i=0;i<64;i++)pad[i]=k[i]^0x36;feed(&s,pad,64);feed(&s,p,n);finish(&s,inner);
 start(&s);for(unsigned i=0;i<64;i++)pad[i]=k[i]^0x5c;feed(&s,pad,64);feed(&s,inner,20);finish(&s,out);
}

void hbc_sha1_hex(const unsigned char *p,unsigned char *out){for(unsigned i=0;i<20;i++){unsigned a=p[i]>>4,b=p[i]&15;out[2*i]=(unsigned char)(a<10?48+a:87+a);out[2*i+1]=(unsigned char)(b<10?48+b:87+b);}}
