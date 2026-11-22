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
extern void hbc_free(void *p, hrt_u64 n);
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
    } else if ((tag & 0xFF) == 5) {
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
        /* an owned dynamic array: the payload points at the CELLS and
           the count lives at payload-8 (the Len tag-8 guard's convention);
           the cells are tagged Dyn pairs */
        hrt_u64 n = *(hrt_u64 *)((char *)payload - 8);
        hrt_u64 i;
        hrt_putc(b, '[');
        for (i = 0; i < n; i++) {
            if (i)
                hrt_putc(b, ',');
            hrt_enc_dyn(b, ((hrt_u64 *)payload)[i * 2], ((hrt_u64 *)payload)[i * 2 + 1], depth);
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

/* ---------------- decode ---------------- */

struct hrt_jd {
    const char *s;
    hrt_u64 len;
    hrt_u64 pos;
};

struct hrt_pair {
    hrt_u64 tag;
    hrt_u64 payload;
};

static void hrt_skipws(struct hrt_jd *jd)
{
    while (jd->pos < jd->len) {
        char c = jd->s[jd->pos];
        if (c == ' ' || c == '\t' || c == '\n' || c == '\r')
            jd->pos++;
        else
            break;
    }
}

static int hrt_peek(struct hrt_jd *jd)
{
    if (jd->pos >= jd->len)
        return -1;
    return (unsigned char)jd->s[jd->pos];
}

static hrt_u64 hrt_pow10(hrt_u64 n);

static int hrt_hex4(struct hrt_jd *jd, hrt_u64 *out)
{
    hrt_u64 v = 0;
    int k;
    for (k = 0; k < 4; k++) {
        int c = hrt_peek(jd);
        hrt_u64 d;
        if (c >= '0' && c <= '9') d = (hrt_u64)(c - '0');
        else if (c >= 'a' && c <= 'f') d = (hrt_u64)(c - 'a' + 10);
        else if (c >= 'A' && c <= 'F') d = (hrt_u64)(c - 'A' + 10);
        else return 0;
        v = v * 16 + d;
        jd->pos++;
    }
    *out = v;
    return 1;
}

static int hrt_dec_string(struct hrt_jd *jd, struct hrt_pair *out)
{
    /* the opening quote is already consumed */
    hrt_u64 cap = 64;
    char *data = (char *)hbc_alloc(cap + 16);
    hrt_u64 n = 0;
    while (jd->pos < jd->len) {
        unsigned char c = (unsigned char)jd->s[jd->pos];
        if (c == '"') {
            jd->pos++;
            *(hrt_u64 *)(data - 16) = n;
            ((hrt_u64 *)(data - 16))[1] = n;
            out->tag = 4;
            out->payload = (hrt_u64)data;
            return 1;
        }
        if (c == '\\') {
            int e = -1;
            hrt_u64 cp;
            jd->pos++;
            if (jd->pos >= jd->len) { hbc_freestr(data); return 0; }
            switch (jd->s[jd->pos]) {
            case '"': e = '"'; break;
            case '\\': e = '\\'; break;
            case '/': e = '/'; break;
            case 'b': e = 8; break;
            case 'f': e = 12; break;
            case 'n': e = 10; break;
            case 'r': e = 13; break;
            case 't': e = 9; break;
            case 'u': {
                hrt_u64 k;
                jd->pos++;
                if (!hrt_hex4(jd, &cp)) { hbc_freestr(data); return 0; }
                /* the codepoint emits as UTF-8 (the standard JSON
                   interchange form); the console-codepage mapping of the
                   oracle machine is an environment-dependent divergence */
                if (cp < 0x80) {
                    data[n++] = (char)cp;
                } else if (cp < 0x800) {
                    data[n++] = (char)(0xC0 | (cp >> 6));
                    data[n++] = (char)(0x80 | (cp & 0x3F));
                } else {
                    data[n++] = (char)(0xE0 | (cp >> 12));
                    data[n++] = (char)(0x80 | ((cp >> 6) & 0x3F));
                    data[n++] = (char)(0x80 | (cp & 0x3F));
                }
                (void)k;
                jd->pos++;
                continue;
            }
            default:
                hbc_freestr(data);
                return 0;
            }
            data[n++] = (char)e;
            jd->pos++;
            continue;
        }
        if (n + 4 > cap) {
            hrt_u64 nc = cap * 2;
            char *np = (char *)hbc_alloc(nc + 16);
            hrt_u64 k;
            np += 16;
            for (k = 0; k < n; k++)
                np[k] = data[k];
            hbc_freestr(data);
            data = np;
            cap = nc;
        }
        data[n++] = (char)c;
        jd->pos++;
    }
    hbc_freestr(data);
    return 0;
}

static int hrt_dec_number(struct hrt_jd *jd, struct hrt_pair *out)
{
    hrt_u64 dec = 0;
    int isfloat = 0;
    double dv = 0.0;
    hrt_i64 iv = 0;
    int neg = 0;
    hrt_u64 k;
    if (jd->pos < jd->len && jd->s[jd->pos] == '-') { neg = 1; jd->pos++; }
    while (jd->pos < jd->len && jd->s[jd->pos] >= '0' && jd->s[jd->pos] <= '9') {
        iv = iv * 10 + (jd->s[jd->pos] - '0');
        jd->pos++;
    }
    if (jd->pos < jd->len && jd->s[jd->pos] == '.') {
        isfloat = 1;
        jd->pos++;
        while (jd->pos < jd->len && jd->s[jd->pos] >= '0' && jd->s[jd->pos] <= '9') {
            dv = dv * 10.0 + (double)(jd->s[jd->pos] - '0');
            jd->pos++;
            dec++;
        }
    }
    if (jd->pos < jd->len && (jd->s[jd->pos] == 'e' || jd->s[jd->pos] == 'E')) {
        int eneg = 0;
        hrt_i64 ex = 0;
        isfloat = 1;
        jd->pos++;
        if (jd->pos < jd->len && (jd->s[jd->pos] == '+' || jd->s[jd->pos] == '-')) {
            eneg = jd->s[jd->pos] == '-';
            jd->pos++;
        }
        while (jd->pos < jd->len && jd->s[jd->pos] >= '0' && jd->s[jd->pos] <= '9') {
            ex = ex * 10 + (jd->s[jd->pos] - '0');
            jd->pos++;
        }
        for (k = 0; k < (hrt_u64)ex; k++) {
            if (eneg) dv /= 10.0; else dv *= 10.0;
        }
        dec = 0;
    }
    if (!isfloat) {
        out->tag = 0;
        out->payload = (hrt_u64)(neg ? -iv : iv);
        return 1;
    }
    /* float: the integer part plus the digit fraction; the JSON literal's
       written decimals become the Dyn float pair's dec (1.5 renders 1.5,
       1.25 renders 1.25) */
    dv = dv / (dec ? (double)hrt_pow10(dec) : 1.0) + (double)iv;
    if (neg) dv = -dv;
    {
        union {
            double d;
            hrt_u64 u;
        } bits;
        bits.d = dv;
        out->tag = 5 | ((dec & 0xFF) << 8);
        out->payload = bits.u;
    }
    return 1;
}

static hrt_u64 hrt_pow10(hrt_u64 n)
{
    hrt_u64 r = 1;
    while (n--) r *= 10;
    return r;
}

/* the value parser: a JSON value -> a Dyn pair; 0 = parse failure */
static int hrt_dec_value(struct hrt_jd *jd, struct hrt_pair *out)
{
    int c;
    hrt_skipws(jd);
    c = hrt_peek(jd);
    if (c < 0)
        return 0;
    if (c == '"') {
        jd->pos++;
        return hrt_dec_string(jd, out);
    }
    if (c == '[') {
        /* dynamic array: the aclone block shape {count, cells at +8},
           cells = tagged Dyn pairs; capacity == length */
        hrt_u64 cap = 4;
        hrt_u64 n = 0;
        hrt_u64 *cells = (hrt_u64 *)hbc_alloc(cap * 16 + 8);
        jd->pos++;
        hrt_skipws(jd);
        if (hrt_peek(jd) == ']') {
            jd->pos++;
            *cells = 0;
            out->tag = 8;
            out->payload = (hrt_u64)(cells + 1);
            return 1;
        }
        for (;;) {
            struct hrt_pair v;
            if (!hrt_dec_value(jd, &v)) {
                hbc_free((char *)cells + 8, 1);
                return 0;
            }
            if (n == cap) {
                hrt_u64 nc = cap * 2;
                hrt_u64 *nbuf = (hrt_u64 *)hbc_alloc(nc * 16 + 8);
                hrt_u64 k;
                for (k = 0; k < n * 2; k++)
                    nbuf[k] = cells[k];
                hbc_free((char *)cells + 8, 1);
                cells = nbuf;
                cap = nc;
            }
            cells[1 + n * 2] = v.tag;
            cells[2 + n * 2] = v.payload;
            n++;
            hrt_skipws(jd);
            if (hrt_peek(jd) == ',') { jd->pos++; continue; }
            if (hrt_peek(jd) == ']') { jd->pos++; break; }
            hbc_free((char *)cells + 8, 1);
            return 0;
        }
        *cells = n;
        out->tag = 8;
        out->payload = (hrt_u64)(cells + 1);
        return 1;
    }
    if (c == '{') {
        /* a JSON object decodes to a hash: the hbc Dyn union has no hash
           cell tag (ValType on it panics by design), so this increment
           names the failure instead of an unrepresentable value */
        hbc_type_error();
    }
    if (c == 't') {
        if (jd->len - jd->pos < 4) return 0;
        if (jd->s[jd->pos+1] == 'r' && jd->s[jd->pos+2] == 'u' && jd->s[jd->pos+3] == 'e') {
            jd->pos += 4;
            out->tag = 3;
            out->payload = 1;
            return 1;
        }
        return 0;
    }
    if (c == 'f') {
        if (jd->len - jd->pos < 5) return 0;
        if (jd->s[jd->pos+1] == 'a' && jd->s[jd->pos+2] == 'l' && jd->s[jd->pos+3] == 's' && jd->s[jd->pos+4] == 'e') {
            jd->pos += 5;
            out->tag = 3;
            out->payload = 0;
            return 1;
        }
        return 0;
    }
    if (c == 'n') {
        if (jd->len - jd->pos < 4) return 0;
        if (jd->s[jd->pos+1] == 'u' && jd->s[jd->pos+2] == 'l' && jd->s[jd->pos+3] == 'l') {
            jd->pos += 4;
            out->tag = 1;
            out->payload = 0;
            return 1;
        }
        return 0;
    }
    if (c == '-' || (c >= '0' && c <= '9'))
        return hrt_dec_number(jd, out);
    return 0;
}

/* SysV entry: rdi/rsi = the JSON text. Returns the decoded Dyn pair in
   rax/rdx; a parse failure decodes to NIL (the oracle: 'not json' -> U). */
struct hrt_pair hbc_json_decode(const char *s, hrt_u64 len)
{
    struct hrt_jd jd;
    struct hrt_pair out;
    jd.s = s;
    jd.len = len;
    jd.pos = 0;
    if (!hrt_dec_value(&jd, &out)) {
        out.tag = 1;
        out.payload = 0;
    }
    return out;
}
