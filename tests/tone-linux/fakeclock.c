#define _GNU_SOURCE
#include <time.h>
#include <sys/select.h>
#include <sys/syscall.h>
#include <sys/time.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
static long long ns=1000000000000LL;
static int fd=-1;
static void logv(const char*s,long long a,long long b){char x[160];if(fd<0)fd=open(getenv("TONE_LOG"),O_WRONLY|O_CREAT|O_TRUNC,0600);int n=snprintf(x,sizeof x,"%s %lld %lld virtual=%lld\n",s,a,b,ns);if(fd>=0)syscall(SYS_write,fd,x,n);}
int clock_gettime(clockid_t id,struct timespec*t){long long val=ns+(id==CLOCK_REALTIME?1795618800000000000LL:0);t->tv_sec=val/1000000000;t->tv_nsec=val%1000000000;logv("clock",id,val);return 0;}
int gettimeofday(struct timeval*t,void*z){(void)z;t->tv_sec=1795618800+ns/1000000000;t->tv_usec=(ns%1000000000)/1000;logv("timeofday",t->tv_sec,t->tv_usec);return 0;}
time_t time(time_t*t){time_t v=1795618800+ns/1000000000;if(t)*t=v;logv("time",v,0);return v;}
int select(int n,fd_set*r,fd_set*w,fd_set*e,struct timeval*t){(void)r;(void)w;(void)e;if(n!=0||!t){logv("UNSUPPORTEDselect",n,0);_exit(88);}logv("select",t->tv_sec,t->tv_usec);ns+=(long long)t->tv_sec*1000000000+t->tv_usec*1000;return 0;}
ssize_t write(int f,const void*b,size_t n){if(f==1)logv("stdout",n,n?*(const unsigned char*)b:0);return syscall(SYS_write,f,b,n);}
