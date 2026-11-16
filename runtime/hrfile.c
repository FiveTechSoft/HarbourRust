/* Own freestanding FILE/SET DEFAULT/SET PATH runtime. No Harbour code. */
typedef unsigned long long U;
typedef unsigned long long usize;
#define MAX 264
static unsigned char hrfile_default[65536],hrfile_paths[65536];
static int hrfile_path_active;
static usize hrfile_dn,hrfile_pn;
static usize hrfile_len(const unsigned char*s){usize n=0;while(s[n])n++;return n;}
static void hrfile_copy(unsigned char*d,const unsigned char*s,usize n){usize i;for(i=0;i<n;i++)d[i]=s[i];d[n]=0;}
void hrfile_set(U which,const unsigned char*s,U n){
 usize max=65535,k=0; if(n>max)n=max;while(k<n&&s[k])k++;n=k;
 if(which){hrfile_path_active=1;hrfile_copy(hrfile_paths,s,n);hrfile_pn=n;}else{hrfile_copy(hrfile_default,s,n);hrfile_dn=n;}
}
#ifdef _WIN32
#define API __attribute__((ms_abi))
extern void* API FindFirstFileW(const unsigned short*,void*);
extern int API FindNextFileW(void*,void*);
extern int API FindClose(void*);
static int hrfile_one(const unsigned char*path){
 /* Harbour's default EN codepage is CP437, not UTF-8. */
 static const unsigned short hrfile_cp437[128]={0xc7,0xfc,0xe9,0xe2,0xe4,0xe0,0xe5,0xe7,0xea,0xeb,0xe8,0xef,0xee,0xec,0xc4,0xc5,0xc9,0xe6,0xc6,0xf4,0xf6,0xf2,0xfb,0xf9,0xff,0xd6,0xdc,0xa2,0xa3,0xa5,0x20a7,0x192,0xe1,0xed,0xf3,0xfa,0xf1,0xd1,0xaa,0xba,0xbf,0x2310,0xac,0xbd,0xbc,0xa1,0xab,0xbb,0x2591,0x2592,0x2593,0x2502,0x2524,0x2561,0x2562,0x2556,0x2555,0x2563,0x2551,0x2557,0x255d,0x255c,0x255b,0x2510,0x2514,0x2534,0x252c,0x251c,0x2500,0x253c,0x255e,0x255f,0x255a,0x2554,0x2569,0x2566,0x2560,0x2550,0x256c,0x2567,0x2568,0x2564,0x2565,0x2559,0x2558,0x2552,0x2553,0x256b,0x256a,0x2518,0x250c,0x2588,0x2584,0x258c,0x2590,0x2580,0x3b1,0xdf,0x393,0x3c0,0x3a3,0x3c3,0xb5,0x3c4,0x3a6,0x398,0x3a9,0x3b4,0x221e,0x3c6,0x3b5,0x2229,0x2261,0xb1,0x2265,0x2264,0x2320,0x2321,0xf7,0x2248,0xb0,0x2219,0xb7,0x221a,0x207f,0xb2,0x25a0,0xa0};
 unsigned short wide[MAX];unsigned char data[592];usize j=0;void*h;int yes=0;
 while(path[j]&&j<MAX-1){unsigned c=path[j];wide[j]=c<128?(unsigned short)c:hrfile_cp437[c-128];j++;}
 wide[j]=0;h=FindFirstFileW(wide,data);if(h==(void*)(U)-1)return 0;
 do{if(!(*(unsigned*)data&22)){yes=1;break;}}while(FindNextFileW(h,data));FindClose(h);return yes;
}
#else
static long hrfile_sys(long nr,long a,long b,long c,long d){long r;register long r10 __asm__("r10")=d;__asm__ volatile("syscall":"=a"(r):"a"(nr),"D"(a),"S"(b),"d"(c),"r"(r10):"rcx","r11","memory");return r;}
static int hrfile_equal(const unsigned char*a,const unsigned char*b,usize n){usize i;for(i=0;i<n;i++)if(a[i]!=b[i])return 0;return 1;}
static int hrfile_class(const unsigned char*p,usize n,unsigned c){
#define EQ(x) (n==sizeof(x)-1&&hrfile_equal(p,(const unsigned char*)x,n))
 if(EQ("digit"))return c>='0'&&c<='9';
 if(EQ("lower"))return c>='a'&&c<='z';if(EQ("upper"))return c>='A'&&c<='Z';
 if(EQ("alpha"))return(c>='a'&&c<='z')||(c>='A'&&c<='Z');
 if(EQ("alnum"))return(c>='a'&&c<='z')||(c>='A'&&c<='Z')||(c>='0'&&c<='9');
 if(EQ("xdigit"))return(c>='0'&&c<='9')||(c>='a'&&c<='f')||(c>='A'&&c<='F');
 if(EQ("space"))return c==' '||(c>=9&&c<=13);if(EQ("blank"))return c==' '||c==9;
 if(EQ("cntrl"))return c<32||c==127;if(EQ("print"))return c>=32&&c<127;
 if(EQ("graph"))return c>32&&c<127;if(EQ("punct"))return c>32&&c<127&&!((c>='0'&&c<='9')||(c>='A'&&c<='Z')||(c>='a'&&c<='z'));
 return -1;
#undef EQ
}
/* One fnmatch token, no pathname slash. Brackets/ranges/ASCII C classes. */
static int hrfile_token(const unsigned char*p,usize*i,unsigned c){
 usize k=*i;unsigned a=p[k++];if(a=='?'){*i=k;return 1;}
 if(a=='\\'){if(!p[k])return 0;a=p[k++];*i=k;return a==c;}
 if(a=='['){usize start=k;int neg=0,yes=0,first=1;if(p[k]=='!'||p[k]=='^'){neg=1;k++;}
  while(p[k]&&(p[k]!=']'||first)){
   unsigned lo,hi;first=0;
   if(yes){
    if(p[k]=='\\'&&p[k+1]){k+=2;continue;}
    if(p[k]=='['&&(p[k+1]==':'||p[k+1]=='.'||p[k+1]=='=')){unsigned kind=p[k+1];usize z=k+2;
     while(p[z]&&!(p[z]==kind&&p[z+1]==']'))z++;if(p[z]){k=z+2;continue;}}
    k++;continue;
   }
   if(p[k]=='['&&(p[k+1]==':'||p[k+1]=='.'||p[k+1]=='=')){
    unsigned kind=p[k+1];usize z=k+2;while(p[z]&&!(p[z]==kind&&p[z+1]==']'))z++;
    if(p[z]){int item=kind==':'?hrfile_class(p+k+2,z-k-2,c):(z==k+3?(int)(c==p[k+2]):-1);
     if(item<0&&!yes)return 0;if(item>0)yes=1;k=z+2;continue;}}
   lo=p[k++];if(lo=='\\'&&p[k])lo=p[k++];
   if(p[k]=='-'&&p[k+1]&&p[k+1]!=']'){k++;hi=p[k++];if(hi=='\\'&&p[k])hi=p[k++];if(c>=lo&&c<=hi)yes=1;}
   else if(c==lo)yes=1;
  }
  if(p[k]==']'&&k>start){*i=k+1;return neg?!yes:yes;}
  k=*i+1;a='[';
 }
 *i=k;return a==c;
}
static int hrfile_match(const unsigned char*p,const unsigned char*s){
 usize i=0,j=0,star=(usize)-1,back=0;
 while(s[j]){if(p[i]=='*'){while(p[i]=='*')i++;star=i;back=j;if(!p[i])return 1;continue;}
  else{usize next=i;if(p[i]&&hrfile_token(p,&next,s[j])){i=next;j++;continue;}}
  if(star==(usize)-1)return 0;i=star;j=++back;
 }
 while(p[i]=='*')i++;return !p[i];
}
static int hrfile_one(const unsigned char*path){
 unsigned char dir[MAX],buf[8192],full[MAX],st[144];usize n=hrfile_len(path),cut=0,i;long fd,got;int yes=0;
 for(i=0;i<n;i++)if(path[i]=='/')cut=i+1;
 if(cut)hrfile_copy(dir,path,cut);else{dir[0]='.';dir[1]=0;}
 if(!path[cut])return 0;
 fd=hrfile_sys(257,-100,(long)dir,65536,0);if(fd<0)return 0;
 while((got=hrfile_sys(217,fd,(long)buf,sizeof buf,0))>0){usize pos=0;
  while(pos+19<(usize)got){unsigned char*d=buf+pos;unsigned reclen=*(unsigned short*)(d+16);const unsigned char*name=d+19;usize ln;
   if(reclen<20||pos+reclen>(usize)got)break;
   if(hrfile_match(path+cut,name)){ln=hrfile_len(name);
    if(cut+ln<MAX){hrfile_copy(full,path,cut);hrfile_copy(full+cut,name,ln);
     long rc=hrfile_sys(262,-100,(long)full,(long)st,0);
     if(rc<0)rc=hrfile_sys(262,-100,(long)full,(long)st,256);
     if(rc==0&&(*(unsigned*)(st+24)&0170000)!=0040000){yes=1;break;}
    }
   }pos+=reclen;
  }if(yes)break;
 }hrfile_sys(3,fd,0,0,0);return yes;
}
#endif
static int hrfile_sep(unsigned c){
#ifdef _WIN32
 return c=='/'||c=='\\'||c==':';
#else
 return c=='/';
#endif
}
static int hrfile_join(const unsigned char*base,usize bn,const unsigned char*s,usize n){
 unsigned char path[MAX];usize cap=MAX-2;
 if(bn>cap)bn=cap;hrfile_copy(path,base,bn);
 if(bn&&n&&!hrfile_sep(base[bn-1])&&bn<cap-1)path[bn++]='/';
 if(n>cap-bn)n=cap-bn;hrfile_copy(path+bn,s,n);return hrfile_one(path);
}
long hrfile_exists(const unsigned char*s,U n){
 usize i,k=0;int explicit_path=0;if(n>=MAX)n=MAX-1;while(k<n&&s[k])k++;n=k;if(!n)return 0;
 for(i=0;i<n;i++){
#ifdef _WIN32
 if(s[i]=='/'||s[i]=='\\'||s[i]==':')explicit_path=1;
#else
 if(s[i]=='/')explicit_path=1;
#endif
 }
 if(explicit_path)return hrfile_join((const unsigned char*)"",0,s,n);
 if(hrfile_join(hrfile_default,hrfile_dn,s,n))return 1;
 if(hrfile_path_active){i=0;for(;;){usize a=i;while(i<hrfile_pn&&hrfile_paths[i]!=
#ifdef _WIN32
 ';'
#else
 ':'
#endif
 )i++;
 if(hrfile_join(hrfile_paths+a,i-a,s,n))return 1;if(i==hrfile_pn)break;i++;
 }}return 0;
}
