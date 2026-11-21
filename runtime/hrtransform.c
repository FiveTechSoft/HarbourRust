/* hrtransform.c - TRANSFORM() layout core for HarbourRust.
 *
 * Original MIT code. Written only from a black-box table of observed
 * inputs and outputs of the reference implementation (tests/transform-bb/
 * spec); no Harbour source was consulted. Every rule below is a hypothesis
 * fitted to those observations; rules the observations do not pin are
 * marked UNVERIFIED and listed in tests/transform-bb/README.md.
 *
 * Freestanding: no libc, no floating point. The compiler renders numbers
 * and dates to text first (Str()/DToC()), this file only lays text out.
 *
 *   hbc_tr_dims(tpl, tlen)  -> packed numeric format request
 *   hbc_tr_apply(kind|neg<<8, s, slen, tpl, tlen, out) -> result length
 *
 * apply is called twice: out == 0 only measures, out != 0 writes.
 */
typedef unsigned long u64;
typedef unsigned char u8;

#define K_STR 0
#define K_NUM 1
#define K_DATE 2
#define K_BOOL 3

#define F_Z 1u
#define F_E 2u
#define F_B 4u
#define F_X 8u
#define F_C 16u
#define F_PAREN 32u
#define F_L 64u
#define F_R 128u
#define F_UP 256u

#define MAXTMP 1024
#define MAXPIC 500 /* picture body columns honoured for numbers; the rest is ignored */

static unsigned parse(const u8 *t, u64 n, const u8 **body, u64 *blen)
{
	unsigned f = 0;
	u64 i = 0;
	*body = t;
	*blen = n;
	if (n == 0 || t[0] != '@')
		return 0;
	i = 1;
	while (i < n && t[i] != ' ') {
		u8 c = t[i];
		if (c >= 'a' && c <= 'z')
			c = (u8)(c - 32);
		if (c == 'Z') f |= F_Z;
		else if (c == 'E') f |= F_E;
		else if (c == 'B') f |= F_B;
		else if (c == 'X') f |= F_X;
		else if (c == 'C') f |= F_C;
		else if (c == '(' || c == ')') f |= F_PAREN;
		else if (c == 'L') f |= F_L;
		else if (c == 'R') f |= F_R;
		else if (c == '!') f |= F_UP;
		i++;
	}
	if (i < n)
		i++; /* the separating blank */
	*body = t + i;
	*blen = n - i;
	return f;
}

static int is_numslot(u8 c)
{
	return c == '9' || c == '#' || c == '*' || c == '$';
}

static u8 upc(u8 c)
{
	return (c >= 'a' && c <= 'z') ? (u8)(c - 32) : c;
}

/* bits 0..23 width without commas, 24..39 decimals, 40 = no picture body
 * (plain Str()), 41 = print the magnitude (the X flag drops the sign). */
u64 hbc_tr_dims(const u8 *t, u64 n)
{
	const u8 *b;
	u64 bl, i, slots = 0, d = 0;
	int dot = 0;
	unsigned f = parse(t, n, &b, &bl);
	u64 r;
	if (bl > MAXPIC)
		bl = MAXPIC;
	for (i = 0; i < bl; i++) {
		if (is_numslot(b[i])) {
			slots++;
			if (dot)
				d++;
		} else if (b[i] == '.' && !dot) {
			dot = 1;
		}
	}
	r = slots + (u64)dot;
	if (r > 0xffffffu)
		r = 0xffffffu;
	if (d > 0xffffu)
		d = 0xffffu;
	r |= d << 24;
	if (slots == 0 && !dot)
		r |= 1ul << 40;
	if (f & F_X)
		r |= 1ul << 41;
	return r;
}

static u64 num(const u8 *s, u64 sl, const u8 *t, u64 tl, int neg, u8 *tmp)
{
	const u8 *b;
	u64 bl, i, j, tw = 0, d = 0, n = 0;
	int dot = 0, over = 0, seendot = 0, zero = 1, anydigit = 0;
	unsigned f = parse(t, tl, &b, &bl);
	u8 sb[MAXTMP];
	u64 sn = 0;
	if (bl > MAXPIC)
		bl = MAXPIC;

	if (bl == 0) {
		/* no picture body: the plain text, only the flags act */
		for (i = 0; i < sl && n < MAXTMP - 8; i++)
			tmp[n++] = s[i];
		for (i = 0; i < n; i++) {
			if (tmp[i] >= '1' && tmp[i] <= '9')
				zero = 0;
			if (tmp[i] >= '0' && tmp[i] <= '9')
				anydigit = 1;
		}
		if ((f & F_Z) && zero && anydigit)
			for (i = 0; i < n; i++)
				tmp[i] = ' ';
		goto flags;
	}
	for (i = 0; i < bl; i++) {
		if (is_numslot(b[i])) {
			tw++;
			if (dot)
				d++;
		} else if (b[i] == '.' && !dot) {
			dot = 1;
			tw++;
		}
	}
	/* s was rendered one column wider than the picture: drop the spare
	 * blank or the leading zero, otherwise the value does not fit. */
	if (sl > MAXPIC + 1)
		over = 1;
	for (i = 0; i < sl && !over; i++)
		if (s[i] == '*')
			over = 1;
	if (!over) {
		if (sl == tw + 1 && s[0] == ' ') {
			s++;
			sl--;
		} else if (sl == tw + 1 && s[0] == '0' && sl > 1 && s[1] == '.') {
			s++;
			sl--;
		} else if (sl == tw + 1 && s[0] == '-' && sl > 2 && s[1] == '0' &&
			   s[2] == '.') {
			sb[0] = '-';
			for (i = 2; i < sl; i++)
				sb[i - 1] = s[i];
			s = sb;
			sl--;
		} else if (sl > tw) {
			over = 1;
		}
	}
	if (over) {
		for (i = 0; i < tw; i++)
			sb[i] = '*';
		if (dot)
			sb[tw - d - 1] = '.';
		s = sb;
		sl = tw;
	} else {
		for (i = 0; i < sl; i++) {
			sb[i] = s[i];
			if (s[i] >= '1' && s[i] <= '9')
				zero = 0;
			if (s[i] >= '0' && s[i] <= '9')
				anydigit = 1;
		}
		s = sb;
	}
	sn = sl;
	if ((f & F_PAREN) && neg && sn > 0) {
		for (i = 0; i < sn; i++)
			if (sb[i] == '-')
				sb[i] = ' ';
		sb[0] = '(';
	}
	if ((f & F_Z) && !over && zero && anydigit) {
		for (i = 0; i < bl && n < MAXTMP - 8; i++)
			tmp[n++] = ' ';
		goto flags;
	}
	j = 0;
	for (i = 0; i < bl && n < MAXTMP - 8; i++) {
		u8 c = b[i];
		if (is_numslot(c)) {
			u8 ch = j < sn ? s[j] : ' ';
			j++;
			if (ch == ' ') {
				if (c == '*' || c == '$')
					ch = c;
				else if (f & F_L)
					ch = '0';
			}
			tmp[n++] = ch;
		} else if (c == '.' && !seendot) {
			seendot = 1;
			tmp[n++] = '.';
			j++;
		} else if (c == ',') {
			u8 p = n ? tmp[n - 1] : ' ';
			if ((p >= '0' && p <= '9') || p == '(')
				tmp[n++] = ',';
			else if (p == '-')
				tmp[n++] = ' ';
			else
				tmp[n++] = p;
		} else if (c == '.') {
			/* UNVERIFIED: a later '.' also takes one text column
			 * (fits the one observed @E overflow row) */
			tmp[n++] = '.';
			j++;
		} else {
			tmp[n++] = c;
		}
	}
	if ((f & F_PAREN) && neg && n < MAXTMP - 8)
		tmp[n++] = ')';
flags:
	if (f & F_B) {
		u64 lead = 0;
		while (lead < n && tmp[lead] == ' ')
			lead++;
		if (lead && lead < n) {
			for (i = lead; i < n; i++)
				tmp[i - lead] = tmp[i];
			for (i = n - lead; i < n; i++)
				tmp[i] = ' ';
		}
	}
	if (f & F_E) {
		for (i = 0; i < n; i++) {
			if (tmp[i] == '.')
				tmp[i] = ',';
			else if (tmp[i] == ',')
				tmp[i] = '.';
		}
	}
	if (((f & F_X) && neg) && n + 3 <= MAXTMP) {
		tmp[n++] = ' ';
		tmp[n++] = 'D';
		tmp[n++] = 'B';
	} else if ((f & F_C) && !neg && n + 3 <= MAXTMP) {
		tmp[n++] = ' ';
		tmp[n++] = 'C';
		tmp[n++] = 'R';
	}
	return n;
}

static int is_strslot(u8 c)
{
	return c == 'X' || c == 'A' || c == 'N' || c == '9' || c == '#' ||
	       c == 'L' || c == 'Y' || c == '!' || c == 'a' || c == 'n' ||
	       c == 'x' || c == 'y' || c == 'l';
}

u64 hbc_tr_apply(u64 kindneg, const u8 *s, u64 sl, const u8 *t, u64 tl, u8 *out)
{
	unsigned kind = (unsigned)(kindneg & 0xff);
	int neg = (int)((kindneg >> 8) & 1);
	const u8 *b;
	u64 bl, i, j, n = 0;
	unsigned f;
	u8 tmp[MAXTMP];

	if (kind == K_NUM) {
		n = num(s, sl, t, tl, neg, tmp);
		if (out)
			for (i = 0; i < n; i++)
				out[i] = tmp[i];
		return n;
	}
	f = parse(t, tl, &b, &bl);
	if (kind == K_DATE) {
		/* The picture does not shape a date; @E swaps day and month. */
		int swap = (f & F_E) && sl >= 5 && (s[2] < '0' || s[2] > '9');
		for (i = 0; i < sl; i++) {
			u8 c = s[i];
			if (swap && i < 2)
				c = s[i + 3];
			else if (swap && i >= 3 && i < 5)
				c = s[i - 3];
			if (out)
				out[i] = c;
		}
		return sl;
	}
	if (kind == K_BOOL) {
		u8 c = sl ? s[0] : 'F';
		for (i = 0; i < bl; i++)
			if (b[i] == 'Y' || b[i] == 'y') {
				c = (c == 'T') ? 'Y' : 'N';
				break;
			}
		if (out)
			out[0] = c;
		return 1;
	}
	/* strings */
	if (bl == 0) {
		for (i = 0; i < sl; i++)
			if (out)
				out[i] = (f & F_UP) ? upc(s[i]) : s[i];
		return sl;
	}
	if (f & F_R) {
		j = 0;
		for (i = 0; i < bl; i++) {
			u8 c = b[i], o;
			if (is_strslot(c)) {
				o = j < sl ? s[j] : ' ';
				j++;
				if (c == '!' || (f & F_UP))
					o = upc(o);
			} else {
				o = c;
			}
			if (out)
				out[n] = o;
			n++;
		}
		return n;
	}
	n = sl < bl ? sl : bl;
	for (i = 0; i < n; i++) {
		u8 c = b[i], o;
		if (is_strslot(c)) {
			o = s[i];
			if (c == '!' || (f & F_UP))
				o = upc(o);
		} else {
			o = c;
		}
		if (out)
			out[i] = o;
	}
	return n;
}
