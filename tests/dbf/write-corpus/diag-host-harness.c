/* host harness: open synthetic DBFs through codec+file layer, print diag */
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <sys/mman.h>
/* test seams for the linux file layer */
long hrdbf_test_syscall3(long nr,long a,long b,long c){
 switch(nr){
 case 0: return read((int)a,(void*)b,(size_t)c);
 case 3: return close((int)a);
 case 8: return lseek((int)a,(off_t)b,(int)c);
 case 11: return munmap((void*)a,(size_t)b);
 }
 return -38;
}
long hrdbf_test_syscall4(long nr,long a,long b,long c,long d){
 if(nr==18) return pwrite64((int)a,(const void*)b,(size_t)c,(off_t)d);
 return -38;
}
long hrdbf_test_open_dbf(const char *path,int writable){
 return open(path,writable?O_RDWR:O_RDONLY);
}
void *hrdbf_test_allocate(size_t n){return mmap(0,n,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);}
#define HRDBF_TEST_SEAMS 1
#include "hrdbf.c"
#include "hrdbf_file_linux.c"

static void run(const char *path){
 hrdbf_file f; hrdbf_error e; memset(&f,0,sizeof f);
 e=hrdbf_file_open(&f,path,1);
 if(!e){printf("%-14s OK count=%u\n",path,f.area.count);hrdbf_file_close(&f);return;}
 printf("%-14s err=%d diag=[%s] area=[%s]\n",path,e,f.diag,f.area.diag);
}
int main(int argc,char**argv){int i;for(i=1;i<argc;i++)run(argv[i]);return 0;}
