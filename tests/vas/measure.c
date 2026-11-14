/* MIT: benchmark-only native parent. Does not become part of hbc/runtime. */
#define _GNU_SOURCE
#include <sys/resource.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
int main(int argc,char**argv){if(argc!=5)return 90;struct timespec a,b;struct rusage u;int status;clock_gettime(CLOCK_MONOTONIC,&a);pid_t p=fork();if(p<0)return 91;if(!p){int out=open(argv[2],O_WRONLY|O_CREAT|O_TRUNC,0600),err=open(argv[3],O_WRONLY|O_CREAT|O_TRUNC,0600);if(out<0||err<0)_exit(92);dup2(out,1);dup2(err,2);close(out);close(err);execl(argv[1],argv[1],(char*)0);_exit(93);}if(wait4(p,&status,0,&u)!=p)return 94;clock_gettime(CLOCK_MONOTONIC,&b);FILE*f=fopen(argv[4],"w");if(!f)return 95;fprintf(f,"{\"seconds\":%.9f,\"peak_rss_kib\":%ld,\"rc\":%d}\n",(b.tv_sec-a.tv_sec)+(b.tv_nsec-a.tv_nsec)/1e9,u.ru_maxrss,WIFEXITED(status)?WEXITSTATUS(status):128+WTERMSIG(status));fclose(f);return 0;}
