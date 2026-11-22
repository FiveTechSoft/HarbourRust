/* Own MIT. hb_jsonEncode() for hbc - clean-room, black-box observed
 * rules only (see tests/jsonencode-bb/README.md for the pinned oracle
 * outputs). Harbour 3.2 observed behaviour:
 *   {"a":1,"b":"txt","c":true,"d":null,"e":1.5}  (no spaces, insertion
 *   order; nil -> null, logical -> true/false)
 *   [1,"x",false] for mixed dynamic arrays, [[1,2],[3]] for nested
 *   floats keep the item's written decimals (1.0 -> "1.0", 2.50 -> "2.50")
 *   strings escape \" \\ \n \t \r and \uXXXX for the other control bytes
 *   a date renders as its DToS text inside a JSON string
 */
typedef long long hrt_i64;
typedef unsigned long long hrt_u64;
typedef unsigned int hrt_u32;

extern void *hbc_alloc(hrt_u64 n);
extern void hbc_freestr(char *p);
extern char *hbc_dtos(hrt_i64 packed);
extern void hbc_type_error(void);
/* hbc_str_f64: xmm0 = value, rdi = packed meta, rsi = width, rdx = dec,
   ecx = flags -> owned text (rax/rdx), hb_itemStr sizing. */
extern char *hbc_str_f64(double v, hrt_u64 meta, hrt_i64 width, hrt_i64 dec, hrt_u32 flags);

struct hrt_jin {
    hrt_u64 kind;   /* 0 nil, 1 int, 2 double, 3 bool, 4 str, 5 date,
                       6 hash, 7 dynarr, 8 strarr, 9 dyncell */
    hrt_i64 i;      /* int/bool/date value, or the container pointer,
                       or the dyncell tag */
    hrt_u64 u;      /* str len, or the dyncell payload */
};

struct hrt_jout {
    char *ptr;
    hrt_u64 len;
};

struct hrt_buf {
    char *p;
    hrt_u64 len;
    hrt_u64 cap;
};

static void hrt_put(struct hrt_buf *b, const char *s, hrt_u64 n)
{
    hrt_u64 i;
    if (b->len + n > b->cap) {
        hrt_u64 nc = b->cap ? b->cap : 256;
        char *np;
        while (nc < b->len + n)
            nc *= 2;
        /* the hbc string convention: a 16-byte {len, cap} header, data
           at +16, freed by hbc_freestr */
        np = (char *)hbc_alloc(nc + 16);
        *(hrt_u64 *)np = nc;
        ((hrt_u64 *)np)[1] = nc;
        np += 16;
        for (i = 0; i < b->len; i++)
            np[i] = b->p[i];
        if (b->p)
            hbc_freestr(b->p);
        b->p = np;
        b->cap = nc;
    }
    for (i = 0; i < n; i++)
        b->p[b->len + i] = s[i];
    b->len += n;
}

static void hrt_putc(struct hrt_buf *b, char c)
{
    hrt_put(b, &c, 1);
}

/* integer -> text (bounded by i64) */
static void hrt_put_i64(struct hrt_buf *b, hrt_i64 v)
{
    char tmp[24];
    int n = 0;
    hrt_u64 a;
    if (v < 0) {
        hrt_putc(b, '-');
        a = (hrt_u64)(-v);
    } else
        a = (hrt_u64)v;
    if (a == 0)
        tmp[n++] = '0';
    while (a) {
        tmp[n++] = (char)('0' + (int)(a % 10));
        a /= 10;
    }
    while (n)
        hrt_putc(b, tmp[--n]);
}

static void hrt_put_str_escaped(struct hrt_buf *b, const char *s, hrt_u64 n)
{
    hrt_u64 i;
    hrt_putc(b, '"');
    for (i = 0; i < n; i++) {
        unsigned char c = (unsigned char)s[i];
        if (c == '"') {
            hrt_put(b, "\\\"", 2);
        } else if (c == '\\') {
            hrt_put(b, "\\\\", 2);
        } else if (c == '\n') {
            hrt_put(b, "\\n", 2);
        } else if (c == '\t') {
            hrt_put(b, "\\t", 2);
        } else if (c == '\r') {
            hrt_put(b, "\\r", 2);
        } else if (c < 0x20) {
            static const char hex[] = "0123456789abcdef";
            hrt_put(b, "\\u00", 4);
            hrt_putc(b, hex[(c >> 4) & 15]);
            hrt_putc(b, hex[c & 15]);
        } else {
            hrt_putc(b, (char)c);
        }
    }
    hrt_putc(b, '"');
}

static double hrt_bits(double *p) { return *p; }

/* a Dyn cell {tag, payload} rendered as a JSON value */
static void hrt_enc_dyn(struct hrt_buf *b, hrt_u64 tag, hrt_u64 payload, int depth)
{
    if (tag == 0 || tag == 9) {
        hrt_put_i64(b, (hrt_i64)payload);
    } else if (tag == 1) {
        hrt_put(b, "null", 4);
    } else if (tag == 3) {
        hrt_put(b, payload ? "true" : "false", payload ? 4 : 5);
    } else if (tag == 2 || tag == 4) {
        /* borrowed or owned string: payload = data pointer, len at -8 */
        hrt_put_str_escaped(b, (const char *)payload, *(hrt_u64 *)((char *)payload - 8));
    } else if (tag == 5) {
        /* float pair: legacy payload = raw bits (dec = tag>>8 or 2);
           heap pair (high bit) payload = {double value, meta} object */
        double v;
        hrt_u64 dec;
        char *t;
        hrt_u64 tl;
        hrt_u64 meta;
        if (tag & 0x8000000000000000ULL) {
            v = hrt_bits((double *)payload);
            meta = ((hrt_u64 *)payload)[1];
            dec = meta & 0xFFFF;
        } else {
            union {
                hrt_u64 u;
                double d;
            } cv;
            cv.u = payload;
            v = cv.d;
            dec = (tag >> 8) & 0xFF;
            if (dec == 0)
                dec = 2;
        }
        /* Str() sizing without an explicit width: a wide item field,
           then the leading padding trimmed; overflow keeps the field. */
        meta = (20ULL << 16) | (dec & 0xFFFF);
        t = hbc_str_f64(v, meta, 0, 0, 0);
        tl = *(hrt_u64 *)((char *)t - 8);
        {
            hrt_u64 k = 0;
            while (k < tl && t[k] == ' ')
                k++;
            hrt_put(b, t + k, tl - k);
        }
        hbc_freestr(t);
    } else if (tag == 8) {
        /* an owned dynamic array block (aclone shape): count at [0],
           tagged Dyn cells at +8 */
        hrt_u64 n = *(hrt_u64 *)payload;
        hrt_u64 i;
        hrt_putc(b, '[');
        for (i = 0; i < n; i++) {
            if (i)
                hrt_putc(b, ',');
            hrt_enc_dyn(b, ((hrt_u64 *)payload)[1 + i * 2], ((hrt_u64 *)payload)[2 + i * 2], depth);
        }
        hrt_putc(b, ']');
    } else {
        hbc_type_error();
    }
}

static void hrt_enc_hash(struct hrt_buf *b, hrt_u64 *entries, hrt_u64 count, int depth)
{
    hrt_u64 i;
    hrt_putc(b, '{');
    for (i = 0; i < count && entries; i++) {
        const char *kp = (const char *)entries[i * 4];
        hrt_u64 kl = entries[i * 4 + 1];
        hrt_u64 tag = entries[i * 4 + 2];
        hrt_u64 payload = entries[i * 4 + 3];
        if (i)
            hrt_putc(b, ',');
        hrt_put_str_escaped(b, kp, kl);
        hrt_putc(b, ':');
        hrt_enc_dyn(b, tag, payload, depth);
    }
    hrt_putc(b, '}');
}

static void hrt_enc_strarr(struct hrt_buf *b, hrt_u64 *cells, hrt_u64 n, int depth)
{
    hrt_u64 i;
    (void)depth;
    hrt_putc(b, '[');
    for (i = 0; i < n && cells; i++) {
        const char *sp = (const char *)cells[i * 2 + 1];
        if (i)
            hrt_putc(b, ',');
        hrt_put_str_escaped(b, sp, *(hrt_u64 *)((char *)sp - 8));
    }
    hrt_putc(b, ']');
}

/* DArr2 ({{1,2},{3}}): the outer block is {count, cells at +8} where
   each cell is an UNTAGGED (inner cells pointer, inner count) pair; the
   inner cells are the tagged Dyn pairs. */
static void hrt_enc_darr2(struct hrt_buf *b, hrt_u64 *cells, hrt_u64 n, int depth)
{
    hrt_u64 i, j;
    if (!cells)
        n = 0;
    hrt_putc(b, '[');
    for (i = 0; i < n; i++) {
        hrt_u64 *inner = (hrt_u64 *)cells[i * 2];
        hrt_u64 in = cells[i * 2 + 1];
        if (i)
            hrt_putc(b, ',');
        hrt_putc(b, '[');
        for (j = 0; j < in; j++) {
            if (j)
                hrt_putc(b, ',');
            hrt_enc_dyn(b, ((hrt_u64 *)inner)[j * 2], ((hrt_u64 *)inner)[j * 2 + 1], depth);
        }
        hrt_putc(b, ']');
    }
    hrt_putc(b, ']');
}

/* SysV entry: rdi = request pointer, xmm0 = double value, rsi = float
   meta (kind 2). Returns the owned JSON text in rax/rdx. */
struct hrt_jout hbc_json_encode(const struct hrt_jin *req, double d, hrt_u64 meta)
{
    struct hrt_buf buf;
    struct hrt_jout out;
    buf.p = (char *)0;
    buf.len = 0;
    buf.cap = 0;
    switch (req->kind) {
    case 0:
        hrt_put(&buf, "null", 4);
        break;
    case 1:
        hrt_put_i64(&buf, req->i);
        break;
    case 2: {
        char *t;
        hrt_u64 tl;
        hrt_u64 k = 0;
        hrt_u64 m = (20ULL << 16) | (meta & 0xFFFF);
        t = hbc_str_f64(d, m, 0, 0, 0);
        tl = *(hrt_u64 *)((char *)t - 8);
        while (k < tl && t[k] == ' ')
            k++;
        hrt_put(&buf, t + k, tl - k);
        hbc_freestr(t);
        break;
    }
    case 3:
        hrt_put(&buf, req->i ? "true" : "false", req->i ? 4 : 5);
        break;
    case 4:
        hrt_put_str_escaped(&buf, (const char *)req->i, req->u);
        break;
    case 5: {
        char *t = hbc_dtos(req->i);
        hrt_u64 tl = *(hrt_u64 *)((char *)t - 8);
        hrt_putc(&buf, '"');
        hrt_put(&buf, t, tl);
        hrt_putc(&buf, '"');
        hbc_freestr(t);
        break;
    }
    case 6:
        if (req->i)
            hrt_enc_hash(&buf, (hrt_u64 *)req->i, req->u, 0);
        else
            hrt_put(&buf, "{}", 2);
        break;
    case 7:
        /* dynamic array slot {cells pointer, count}: tagged 16-byte
           Dyn cells {tag, payload} */
        {
            hrt_u64 *cells = (hrt_u64 *)req->i;
            hrt_u64 n = req->u;
            hrt_u64 i;
            if (!cells) {
                hrt_put(&buf, "[]", 2);
                break;
            }
            hrt_putc(&buf, '[');
            for (i = 0; i < n; i++) {
                if (i)
                    hrt_putc(&buf, ',');
                hrt_enc_dyn(&buf, cells[i * 2], cells[i * 2 + 1], 0);
            }
            hrt_putc(&buf, ']');
        }
        break;
    case 8:
        hrt_enc_strarr(&buf, (hrt_u64 *)req->i, req->u, 0);
        break;
    case 9:
        hrt_enc_dyn(&buf, (hrt_u64)req->i, req->u, 0);
        break;
    case 10:
        hrt_enc_darr2(&buf, (hrt_u64 *)req->i, req->u, 0);
        break;
    default:
        hbc_type_error();
    }
    out.ptr = buf.p;
    out.len = buf.len;
    return out;
}
