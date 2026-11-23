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

static hrt_u64 g_date_fmt = 0;     /* 0..6, the layout table row */
static hrt_u64 g_century = 0;      /* 0: two-digit year, 1: four digits */

void hbc_date_set_fmt(hrt_u64 f) { g_date_fmt = f; }
void hbc_date_set_century(hrt_u64 c) { g_century = c; }

struct hrt_dout {          /* SysV: returned in rax/rdx */
    char *ptr;
    hrt_u64 len;
};

static const unsigned char g_layouts[7][4] = {
    { 0, '/', 1, '/' },   /* AMERICAN: M / D / Y */
    { 2, '.', 0, '.' },   /* ANSI: Y . M . D */
    { 1, '/', 0, '/' },   /* BRITISH: D / M / Y */
    { 1, '.', 0, '.' },   /* GERMAN: D . M . Y */
    { 1, '-', 0, '-' },   /* ITALIAN: D - M - Y */
    { 0, '-', 1, '-' },   /* USA: M - D - Y */
    { 2, '/', 0, '/' }    /* JAPANESE: Y / M / D */
};

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
    row = g_layouts[g_date_fmt % 7];
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
