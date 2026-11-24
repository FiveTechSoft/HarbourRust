/* Own MIT. The runtime date-render state and layout core for hbc -
 * clean-room, black-box observed rules only (the SET DATE / SET CENTURY
 * matrix measured against native Windows Harbour 3.2; see
 * tests/setdate-bb/README.md):
 *   AMERICAN MM/DD/YY   ANSI YYYY.MM.DD   BRITISH DD/MM/YY
 *   GERMAN DD.MM.YY     ITALIAN DD-MM-YY  USA MM-DD-YY
 *   JAPANESE YYYY/MM/DD (FRENCH shares the BRITISH layout)
 * SET CENTURY ON widens the year to four digits; OFF keeps two. The
 * month/day fields are always two zero-padded digits. The empty date
 * renders the layout with every digit position blank ("  /  /  ", or
 * "  /  /    " with century on). DToS never changes.
 */
typedef unsigned long long hrt_u64;

extern void *hbc_alloc(hrt_u64 n);

static hrt_u64 g_date_fmt = 0;     /* 0..8 layouts, 9..14 whitelisted measured families */
static hrt_u64 g_century = 0;      /* 0: two-digit year, 1: four digits */

struct hrt_dout {          /* SysV: returned in rax/rdx */
    char *ptr;
    hrt_u64 len;
};

static const unsigned char g_layouts[9][4] = {
    { 0, '/', 1, '/' },   /* AMERICAN: M / D / Y */
    { 2, '.', 0, '.' },   /* ANSI: Y . M . D */
    { 1, '/', 0, '/' },   /* BRITISH: D / M / Y */
    { 1, '.', 0, '.' },   /* GERMAN: D . M . Y */
    { 1, '-', 0, '-' },   /* ITALIAN: D - M - Y */
    { 0, '-', 1, '-' },   /* USA: M - D - Y */
    { 2, '/', 0, '/' },   /* JAPANESE: Y / M / D */
    { 2, '/', 1, '/' },   /* measured yyyy/dd/mm: Y / D / M */
    { 1, '/', 0, '/' }    /* measured ddd/mmm/yy: D / M / Y */
};

static char g_mask[17] = "mm/dd/yy";
static hrt_u64 g_mask_len = 8;
static void hrt_mask_standard(hrt_u64 upper)
{
    const unsigned char *row = g_layouts[g_date_fmt % 9];
    hrt_u64 fields[3],i,j,n=0;
    fields[0]=row[0];fields[1]=row[2];fields[2]=3-fields[0]-fields[1];
    for(i=0;i<3;i++) {
        hrt_u64 k=fields[i],count=k==2&&g_century?4:2;
        if(g_date_fmt==8&&k!=2)count=3;
        char c=k==0?'m':k==1?'d':'y';
        if(upper)c=(char)(c-'a'+'A');
        for(j=0;j<count;j++)g_mask[n++]=c;
        if(i<2)g_mask[n++]=(char)row[i==0?1:3];
    }
    g_mask_len=n;
}
void hbc_date_set_fmt(hrt_u64 f) { g_date_fmt = f; hrt_mask_standard(0); }
void hbc_date_set_century(hrt_u64 c) {
    if(g_century!=c){
        g_century=c;
        if(g_date_fmt<9)hrt_mask_standard(1);
        else {
            char next[17];hrt_u64 i,j=0,k=0,done=0;
            for(i=0;i<g_mask_len;i++) {
                char ch=g_mask[i];if(ch>='a'&&ch<='z')ch=(char)(ch-'a'+'A');
                if(ch=='Y'&&!done){for(k=0;k<(c?4:2);k++)next[j++]='Y';while(i+1<g_mask_len&&(g_mask[i+1]=='y'||g_mask[i+1]=='Y'))i++;done=1;}
                else next[j++]=ch;
            }
            if(!done){hrt_u64 n=c?4:2;for(i=j;i>0;i--)next[i+n-1]=next[i-1];for(i=0;i<n;i++)next[i]='Y';j+=n;}
            for(i=0;i<j;i++)g_mask[i]=next[i];g_mask_len=j;
        }
    }
}
hrt_u64 hbc_date_get_century(void) { return g_century; }
struct hrt_dout hbc_date_get_mask(void)
{
    struct hrt_dout out;hrt_u64 i;char *b=(char*)hbc_alloc(g_mask_len+16);
    ((hrt_u64*)b)[0]=g_mask_len;((hrt_u64*)b)[1]=g_mask_len;
    for(i=0;i<g_mask_len;i++)b[16+i]=g_mask[i];
    out.ptr=b+16;out.len=g_mask_len;return out;
}
/* Only compiler-checked literals or runtime-validated masks reach here. */
void hbc_date_set_mask(const char *mask,hrt_u64 len,hrt_u64 fmt,hrt_u64 century)
{
    hrt_u64 i;g_date_fmt=fmt;g_century=century;g_mask_len=len;
    for(i=0;i<len;i++)g_mask[i]=mask[i];
}

/* two zero-padded digits at p */
static void hrt_w2(char *p, hrt_u64 v)
{
    p[0] = (char)('0' + (v / 10) % 10);
    p[1] = (char)('0' + v % 10);
}

/* field k (0 month, 1 day, 2 year) rendered at p; returns the bytes */
static hrt_u64 hrt_field(char *p, hrt_u64 k, hrt_u64 d, hrt_u64 m, hrt_u64 y)
{
    hrt_u64 v;
    if (k == 0) { hrt_w2(p, m); return 2; }
    if (k == 1) { hrt_w2(p, d); return 2; }
    if (g_century) {
        hrt_w2(p, y / 100);
        hrt_w2(p + 2, y % 100);
        return 4;
    }
    v = y % 100;
    hrt_w2(p, v);
    return 2;
}

/* rdi = packed date, rsi = buffer (>= 10 bytes) -> rax = the length */
hrt_u64 hbc_date_core_c(hrt_u64 packed, char *buf)
{
    hrt_u64 d, m, y, f1, f2, f3, i;
    const unsigned char *row;
    d = packed % 100;
    m = (packed / 100) % 100;
    y = packed / 10000;
    if (!g_century)
        y %= 100;
    if(g_date_fmt>=9) {
        /* Whitelisted original dates2 families only. The observed output
         * cap changes the width of a field at the right edge. */
        hrt_u64 pos=0,seen=0;
        while(pos<g_mask_len&&pos<10) {
            char ch=g_mask[pos];hrt_u64 bit=0,run=0,width,k,v;
            if(ch>='a'&&ch<='z')ch=(char)(ch-'a'+'A');
            if(ch=='M')bit=1;else if(ch=='D')bit=2;else if(ch=='Y')bit=4;
            if(bit&&!(seen&bit)) {
                while(pos+run<g_mask_len&&pos+run<10) {char x=g_mask[pos+run];if(x>='a'&&x<='z')x=(char)(x-'a'+'A');if(x!=ch)break;run++;}
                width=run>4?1:run;v=bit==1?m:bit==2?d:packed/10000;
                for(k=0;k<width;k++) {
                    hrt_u64 div=1,t=width-k-1;
                    if(bit!=4&&t>0)t=1;
                    while(t--)div*=10;
                    buf[pos+k]=packed?(char)('0'+(v/div)%10):' ';
                }
                pos+=width;seen|=bit;
            }else buf[pos++]=ch;
        }
        return pos;
    }
    if(g_date_fmt==8) {
        /* Measured triple widths repeat the tens position, then the units.
         * The year stays two digits, even in the 12-byte yyyy mask. */
        buf[0]=(char)('0'+d/10);hrt_w2(buf+1,d);buf[3]='/';
        buf[4]=(char)('0'+m/10);hrt_w2(buf+5,m);buf[7]='/';hrt_w2(buf+8,y%100);
        if(!packed)for(i=0;i<10;i++)if(buf[i]>='0'&&buf[i]<='9')buf[i]=' ';
        return 10;
    }
    row = g_layouts[g_date_fmt % 9];
    f1 = row[0];
    f2 = row[2];
    f3 = 3 - f1 - f2;
    {
        char *p = buf;
        p += hrt_field(p, f1, d, m, y);
        *p++ = (char)row[1];
        p += hrt_field(p, f2, d, m, y);
        *p++ = (char)row[3];
        p += hrt_field(p, f3, d, m, y);
        /* the empty date keeps the layout's separators and blanks every
         * digit position (Harbour: "  /  /  ", "    .  .  ", ...) */
        if (!packed)
            for (i = 0; buf + i < p; i++)
                if (buf[i] >= '0' && buf[i] <= '9')
                    buf[i] = ' ';
        return (hrt_u64)(p - buf);
    }
}

/* owned-string entry for DToC: rdi = packed -> rax/rdx owned text */
struct hrt_dout hbc_dtoc_c(hrt_u64 packed)
{
    struct hrt_dout out;
    char scratch[16];
    char *b;
    hrt_u64 n, i;
    n = hbc_date_core_c(packed, scratch);
    b = (char *)hbc_alloc(n + 16);
    *(hrt_u64 *)b = n;
    ((hrt_u64 *)b)[1] = n;
    for (i = 0; i < n; i++)
        b[16 + i] = scratch[i];
    out.ptr = b + 16;
    out.len = n;
    return out;
}

/* Validate only the bounded measured layouts supported by this increment.
 * Result encodes layout bits0..3 and century bit4; invalid is all ones. */
hrt_u64 hbc_date_check_mask(const char *mask,hrt_u64 len)
{
    hrt_u64 f,c,i,j,pos,count,field;char actual,expect;
    {
        const char *families[18]={"yyy/mm/ddd","yy/mm/ddd","yyyy/mm/ddd","yyy/m/d/yyy","yy/m/d/yyy","yyyy/m/d/yyy","m/d/y/m/d","m/d/yy/m/d","m/d/yyyy/m/d","mmmm/ddddd","yymmmm/ddddd","yyyymmmm/ddddd","mmmmm/dd","yymmmmm/dd","yyyymmmmm/dd","yyy-mm-dd","yy-mm-dd","yyyy-mm-dd"};
        hrt_u64 n;
        for(n=0;n<18;n++) {
            for(i=0;i<len&&families[n][i];i++){actual=mask[i];if(actual>='A'&&actual<='Z')actual=(char)(actual-'A'+'a');if(actual!=families[n][i])break;}
            if(i==len&&!families[n][i])return (9+n/3)|((n%3==2?1:0)<<4);
        }
    }
    if(len==10||len==12) {
        const char *triple=len==10?"ddd/mmm/yy":"ddd/mmm/yyyy";
        for(i=0;i<len;i++){actual=mask[i];if(actual>='A'&&actual<='Z')actual=(char)(actual-'A'+'a');if(actual!=triple[i])break;}
        if(i==len)return 8|((len==12?1:0)<<4);
    }
    if(len!=8&&len!=10)return ~(hrt_u64)0;
    for(f=0;f<8;f++)for(c=0;c<2;c++) {
        const unsigned char *row=g_layouts[f];hrt_u64 fields[3];
        fields[0]=row[0];fields[1]=row[2];fields[2]=3-fields[0]-fields[1];pos=0;
        for(i=0;i<3;i++) {
            field=fields[i];count=field==2&&c?4:2;expect=field==0?'m':field==1?'d':'y';
            for(j=0;j<count;j++) {
                if(pos>=len)break;
                actual=mask[pos];if(actual>='A'&&actual<='Z')actual=(char)(actual-'A'+'a');
                if(actual!=expect)break;pos++;
            }
            if(j!=count)break;
            if(i<2){if(pos>=len||mask[pos]!=(char)row[i==0?1:3])break;pos++;}
        }
        if(i==3&&pos==len)return f|(c<<4);
    }
    return ~(hrt_u64)0;
}

hrt_u64 hbc_date_mask_has_year(void) {hrt_u64 i;for(i=0;i<g_mask_len;i++)if(g_mask[i]=='y'||g_mask[i]=='Y')return 1;return 0;}
