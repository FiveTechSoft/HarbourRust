/* Original MIT. Counted-byte console renderer derived only from external
 * GTSTD executable observations, not from any Harbour source or library.
 * Fixed 80 columns x 25 rows, ordinary headless Linux profile only.
 * Raw output is handled elsewhere and does not change this screen state.
 */
#include <stdint.h>
#include <stddef.h>
extern void hbc_gtstd_write(const unsigned char *,size_t);
static unsigned char screen[25][80],shown[25][80];
static uint64_t row,highest,printed_row;
static unsigned col,printed_col,dirty=80,ready;
static void init(void){if(!ready){for(unsigned y=0;y<25;y++)for(unsigned x=0;x<80;x++)screen[y][x]=shown[y][x]=32;ready=1;}}
static void lines(uint64_t count){const unsigned char lf=10;while(count--){hbc_gtstd_write(&lf,1);}}
static void flush(void){
 unsigned char *p=screen[row%25];unsigned end=80;while(end&&p[end-1]==32)end--;
 if(end&&dirty<80){
  if(row!=printed_row||dirty<printed_col){
   if(row>printed_row)lines(row-printed_row);else if(printed_col)lines(1);
   printed_row=row;printed_col=0;
  }
  if(end>printed_col){unsigned char bytes[80];for(unsigned i=printed_col;i<end;i++){unsigned b=p[i];bytes[i-printed_col]=(unsigned char)(b<32||b==127?46:b);}hbc_gtstd_write(bytes,end-printed_col);printed_col=end;}
 }
 for(unsigned i=0;i<80;i++)shown[row%25][i]=screen[row%25][i];
 dirty=80;
}
static void down(void){
 flush();row++;col=0;
 if(row>highest){highest=row;for(unsigned i=0;i<80;i++)screen[row%25][i]=32;}
}
void hbc_gtstd_render(const unsigned char *p,size_t n){
 init();
 for(size_t i=0;i<n;i++){
  unsigned b=p[i];
  if(b==7){flush();hbc_gtstd_write(p+i,1);continue;}
  if(b==8){
   if(col)col--;else if(row>(highest>24?highest-24:0)){row--;col=79;}else continue;
   if(screen[row%25][col]!=32){screen[row%25][col]=32;if(col<dirty)dirty=col;}
   unsigned changed=0;for(unsigned x=0;x<80;x++)if(screen[row%25][x]!=shown[row%25][x]){changed=1;break;}
   if(changed)flush();else dirty=80;continue;
  }
  if(b==13){flush();col=0;continue;}
  if(b==10){down();continue;}
  if(screen[row%25][col]!=b){screen[row%25][col]=(unsigned char)b;if(col<dirty)dirty=col;}col++;
  if(col==80)down();
 }
}
void hbc_gtstd_finish(void){flush();}
void hbc_gtstd_close(void){flush();if(row>printed_row){lines(row-printed_row);printed_row=row;printed_col=0;}}
