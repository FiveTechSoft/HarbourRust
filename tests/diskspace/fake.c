#define _GNU_SOURCE
#include <sys/statvfs.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <stdio.h>
int statvfs(const char *p,struct statvfs *s) {
 const char *v=getenv("HB_TEST_STAT");long long b=0,t=0,f=0,a=0;
 if(!v||sscanf(v,"%lld,%lld,%lld,%lld",&b,&t,&f,&a)!=4){errno=ENOENT;return -1;}
 memset(s,0,sizeof(*s));s->f_bsize=b;s->f_frsize=b/2;s->f_blocks=t;s->f_bfree=f;s->f_bavail=a;return 0;
}
