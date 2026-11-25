#define _GNU_SOURCE
#include <time.h>
#include <sys/time.h>
#include <stdlib.h>
static long long stamp(void) { const char *v=getenv("HB_TEST_NS"); return v?strtoll(v,0,10):0; }
int clock_gettime(clockid_t id,struct timespec *t) {long long n=stamp();t->tv_sec=n/1000000000;t->tv_nsec=n%1000000000;return 0;}
int gettimeofday(struct timeval *t,void *z) {long long n=stamp();t->tv_sec=n/1000000000;t->tv_usec=(n%1000000000)/1000;return 0;}
time_t time(time_t *p) {time_t n=stamp()/1000000000;if(p)*p=n;return n;}
