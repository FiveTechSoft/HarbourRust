#include <stdio.h>
#include <stdlib.h>
#include <string.h>
typedef unsigned long u64;
u64 hbc_tr_dims(const unsigned char*,u64);
u64 hbc_tr_apply(u64,const unsigned char*,u64,const unsigned char*,u64,unsigned char*);
int main(){ srand(7); const char al[]="9#*$.,@ZEBXC()LR!AXY- 0abc";
 for(int it=0;it<200000;it++){
  u64 tl=rand()%(it%50==0?3000:40); unsigned char*t=malloc(tl+1);
  for(u64 i=0;i<tl;i++)t[i]=al[rand()%(sizeof al-1)];
  if(rand()%2&&tl)t[0]='@';
  u64 sl=rand()%(it%50==0?1500:30); unsigned char*s=malloc(sl+1);
  for(u64 i=0;i<sl;i++)s[i]="0123456789.-* ab"[rand()%16];
  int k=rand()%4; u64 kn=k|((u64)(rand()&1)<<8);
  hbc_tr_dims(t,tl);
  u64 n=hbc_tr_apply(kn,s,sl,t,tl,0); unsigned char*o=malloc(n+1);
  u64 m=hbc_tr_apply(kn,s,sl,t,tl,o); if(m!=n){puts("MISMATCH");return 1;}
  free(t);free(s);free(o);}
 puts("ok");}
