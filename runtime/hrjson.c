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
    const hrt_u64 max = ~(hrt_u64)0;
    if (n > max - b->len || b->len + n > max - 16) hbc_type_error();
    if (!b->p || b->len + n > b->cap) {
        hrt_u64 nc = b->cap ? b->cap : 256;
        char *np;
        while (nc < b->len + n) {
            if (nc > (max - 16) / 2) { nc = b->len + n; break; }
            nc *= 2;
        }
        /* the hbc string convention: a 16-byte {cap, len} header, data
           at +16, freed by hbc_freestr */
        np = (char *)hbc_alloc(nc + 16);
        *(hrt_u64 *)np = nc;
        ((hrt_u64 *)np)[1] = b->len;
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
    ((hrt_u64 *)b->p)[-1] = b->len;
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
        a = 0 - (hrt_u64)v;
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
    unsigned depth;
    int unsupported;
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
    /* Every path, including escapes, uses the same capacity/length owner. */
    struct hrt_buf b = { (char *)0, 0, 0 };
    while (jd->pos < jd->len) {
        unsigned char c = (unsigned char)jd->s[jd->pos++];
        if (c == '"') {
            /* The empty string still has an owned, initialized header. */
            hrt_put(&b, "", 0);
            out->tag = 4;
            out->payload = (hrt_u64)b.p;
            return 1;
        }
        if (c < 0x20) goto bad;
        if (c == '\\') {
            int e;
            hrt_u64 cp;
            if (jd->pos >= jd->len) goto bad;
            e = (unsigned char)jd->s[jd->pos++];
            switch (e) {
            case '"': case '\\': case '/': break;
            case 'b': e = 8; break;
            case 'f': e = 12; break;
            case 'n': e = 10; break;
            case 'r': e = 13; break;
            case 't': e = 9; break;
            case 'u':
                if (!hrt_hex4(jd, &cp)) goto bad;
                if (cp >= 0xD800 && cp <= 0xDBFF) {
                    hrt_u64 low;
                    if (jd->len - jd->pos < 2 || jd->s[jd->pos] != '\\' || jd->s[jd->pos+1] != 'u') goto bad;
                    jd->pos += 2;
                    if (!hrt_hex4(jd, &low) || low < 0xDC00 || low > 0xDFFF) goto bad;
                    cp = 0x10000 + ((cp - 0xD800) << 10) + low - 0xDC00;
                } else if (cp >= 0xDC00 && cp <= 0xDFFF) goto bad;
                if (cp < 0x80) {
                    hrt_putc(&b, (char)cp);
                } else if (cp < 0x800) {
                    hrt_putc(&b, (char)(0xC0 | (cp >> 6)));
                    hrt_putc(&b, (char)(0x80 | (cp & 0x3F)));
                } else if (cp < 0x10000) {
                    hrt_putc(&b, (char)(0xE0 | (cp >> 12)));
                    hrt_putc(&b, (char)(0x80 | ((cp >> 6) & 0x3F)));
                    hrt_putc(&b, (char)(0x80 | (cp & 0x3F)));
                } else {
                    hrt_putc(&b, (char)(0xF0 | (cp >> 18)));
                    hrt_putc(&b, (char)(0x80 | ((cp >> 12) & 0x3F)));
                    hrt_putc(&b, (char)(0x80 | ((cp >> 6) & 0x3F)));
                    hrt_putc(&b, (char)(0x80 | (cp & 0x3F)));
                }
                (void)k;
                continue;
            default: goto bad;
            }
            hrt_putc(&b, (char)e);
        } else {
            hrt_putc(&b, (char)c);
        }
    }
bad:
    if (b.p) hbc_freestr(b.p);
    return 0;
}

static int hrt_dec_number(struct hrt_jd *jd, struct hrt_pair *out)
{
    hrt_u64 mag = 0, dec = 0;
    const hrt_u64 maxint = 9223372036854775807ULL;
    int neg = 0, isfloat = 0, int_overflow = 0;
    int expneg = 0;
    unsigned exponent = 0;
    double value = 0.0, place = 0.1;
    hrt_u64 start;
    if (hrt_peek(jd) == '-') { neg = 1; jd->pos++; }
    start = jd->pos;
    while (hrt_peek(jd) >= '0' && hrt_peek(jd) <= '9') {
        unsigned digit = (unsigned)(jd->s[jd->pos++] - '0');
        if (mag > (maxint + (unsigned)neg - digit) / 10) int_overflow = 1;
        if (!int_overflow) mag = mag * 10 + digit;
        value = value * 10.0 + digit;
    }
    if (jd->pos == start) return 0;
    if (jd->pos - start > 1 && jd->s[start] == '0') return 0;
    if (hrt_peek(jd) == '.') {
        isfloat = 1; jd->pos++; start = jd->pos;
        while (hrt_peek(jd) >= '0' && hrt_peek(jd) <= '9') {
            value += (jd->s[jd->pos++] - '0') * place;
            place *= 0.1;
            if (++dec > 255) return 0; /* representable metadata boundary */
        }
        if (jd->pos == start) return 0;
    }
    if (hrt_peek(jd) == 'e' || hrt_peek(jd) == 'E') {
        isfloat = 1; jd->pos++;
        if (hrt_peek(jd) == '+' || hrt_peek(jd) == '-') {
            expneg = hrt_peek(jd) == '-'; jd->pos++;
        }
        start = jd->pos;
        while (hrt_peek(jd) >= '0' && hrt_peek(jd) <= '9') {
            unsigned digit = (unsigned)(jd->s[jd->pos++] - '0');
            if (exponent > (308U - digit) / 10U) return 0;
            exponent = exponent * 10 + digit;
        }
        if (jd->pos == start) return 0;
        /* At most nine iterations, never a loop proportional to input exponent. */
        {
            double factor = 10.0;
            unsigned e = exponent;
            while (e) {
                if (e & 1) value = expneg ? value / factor : value * factor;
                e >>= 1;
                if (e) factor *= factor;
            }
        }
        dec = 0;
    }
    if (!isfloat) {
        if (int_overflow) return 0;
        out->tag = 0;
        out->payload = neg ? 0 - mag : mag;
    } else {
        union { double d; hrt_u64 u; } bits;
        bits.d = neg ? -value : value;
        if ((bits.u & 0x7FF0000000000000ULL) == 0x7FF0000000000000ULL) return 0;
        out->tag = 5 | ((dec & 0xFF) << 8);
        out->payload = bits.u;
    }
    return 1;
}

/* Parser-owned pairs are a tree, never aliased. The public array owner uses
   the same tag-8 recursive layout and exact count-sized allocation. */
static void hrt_drop_pair(struct hrt_pair v)
{
    if (v.tag == 4) hbc_freestr((char *)v.payload);
    else if (v.tag == 8) {
        hrt_u64 *cells = (hrt_u64 *)v.payload;
        hrt_u64 n = cells[-1], i;
        for (i = 0; i < n; i++) {
            struct hrt_pair child = {cells[i*2], cells[i*2+1]};
            hrt_drop_pair(child);
        }
        hbc_free(cells, 16);
    }
}

static void hrt_drop_array(hrt_u64 *base, hrt_u64 count)
{
    hrt_u64 i;
    for (i = 0; i < count; i++) {
        struct hrt_pair child = {base[1+i*2], base[2+i*2]};
        hrt_drop_pair(child);
    }
    hbc_free(base+1, 16);
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
        hrt_u64 cap = 4, n = 0;
        hrt_u64 *base;
        if (jd->depth >= 128) return 0;
        jd->depth++;
        base = (hrt_u64 *)hbc_alloc(cap * 16 + 8);
        base[0] = cap;
        jd->pos++;
        hrt_skipws(jd);
        if (hrt_peek(jd) != ']') {
            for (;;) {
                struct hrt_pair v;
                if (!hrt_dec_value(jd, &v)) goto array_bad;
                if (n == cap) {
                    hrt_u64 nc, k;
                    hrt_u64 *next;
                    if (cap > ((~(hrt_u64)0) - 8) / 32) {
                        hrt_drop_pair(v); goto array_bad;
                    }
                    nc = cap * 2;
                    next = (hrt_u64 *)hbc_alloc(nc * 16 + 8);
                    next[0] = nc;
                    for (k = 0; k < n * 2; k++) next[1+k] = base[1+k];
                    hbc_free(base+1, 16);
                    base = next; cap = nc;
                }
                base[1+n*2] = v.tag;
                base[2+n*2] = v.payload;
                n++;
                hrt_skipws(jd);
                if (hrt_peek(jd) == ',') { jd->pos++; continue; }
                if (hrt_peek(jd) == ']') break;
                goto array_bad;
            }
        }
        jd->pos++;
        if (n != cap) {
            hrt_u64 k;
            hrt_u64 *exact = (hrt_u64 *)hbc_alloc(n * 16 + 8);
            exact[0] = n;
            for (k = 0; k < n * 2; k++) exact[1+k] = base[1+k];
            hbc_free(base+1, 16);
            base = exact;
        }
        out->tag = 8;
        out->payload = (hrt_u64)(base+1);
        jd->depth--;
        return 1;
array_bad:
        hrt_drop_array(base, n);
        jd->depth--;
        return 0;
    }
    if (c == '{') {
        /* Defer the named unsupported-object error until partial owners unwind. */
        jd->unsupported = 1;
        return 0;
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
    jd.depth = 0;
    jd.unsupported = 0;
    if (!hrt_dec_value(&jd, &out)) {
        out.tag = 1;
        out.payload = 0;
    }
    if (jd.unsupported) hbc_type_error();
    return out;
}
