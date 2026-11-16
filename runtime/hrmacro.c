/* Own MIT. M0 contextual parse/fold/runtime separation; terminal-only boundary. */
#include "hrmacro.h"

extern unsigned char *hrm_alloc(size_t len);
extern void hrm_free(unsigned char *p);
extern hrm_cell hrm_float(uint64_t bits, uint64_t meta);
extern double hrm_exp(double x);
extern double hrm_log(double x);
extern double hrm_fmod(double x, double y);
extern double hrm_powf(double x, double y);
extern void hrm_fail(const unsigned char *msg, size_t len) __attribute__((noreturn));

/* V_ERR is a deferred Harbour error: Harbour folds the expression before
 * it resolves names or raises operand errors, so `.F. .AND. hidden` is .F.
 * and only an error that survives folding reaches the program. The first
 * error in evaluation order wins. */
enum { V_NIL, V_INT, V_DBL, V_LOG, V_STR, V_ERR };

typedef struct {
  int kind;
  int64_t i;            /* V_INT value, V_LOG 0/1 */
  double d;             /* V_DBL value */
  int dec;              /* V_DBL decimals */
  const unsigned char *s; /* V_STR bytes */
  size_t n;             /* V_STR length */
  uint64_t meta;       /* exact binding float metadata, or calculated operator metadata */
  int literal;         /* source provenance only, never inferred from binding tag9 */
  int owned;            /* V_STR: s came from hrm_alloc */
  const char *builtin; /* deferred terminal builtin frame, static spelling */
  unsigned char ebuf[512]; /* V_ERR message */
  size_t en;
} val;

enum { T_END, T_NUM, T_STR, T_IDENT, T_OP, T_LPAREN, T_RPAREN, T_COMMA, T_TRUE, T_FALSE, T_NIL, T_AND, T_OR, T_NOT, T_AMP };

typedef struct {
  const unsigned char *p, *end;
  int tok;
  const unsigned char *ts; size_t tn; /* token text (strings: contents) */
  int op;                              /* T_OP operator code */
  int error; const char *message;
  val num;                             /* T_NUM value */
} lex;

/* Operator codes. */
enum { O_PLUS = 1, O_MINUS, O_STAR, O_SLASH, O_PCT, O_POW, O_EQ, O_EXEQ, O_NE, O_LT, O_LE, O_GT, O_GE, O_DOLLAR, O_BANG };

static void lex_fail(lex *L,const char*m){L->error=1;L->message=m;L->tok=T_END;L->p=L->end;}
static int is_space(int c) { return c == ' ' || c == '\t' || c == '\r' || c == '\n'; }
static int is_digit(int c) { return c >= '0' && c <= '9'; }
static int is_alpha(int c) { return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_'; }
static int upper(int c) { return (c >= 'a' && c <= 'z') ? c - 32 : c; }

static double pow10i(int n) { double r = 1.0; while (n-- > 0) r *= 10.0; return r; }

/* Dot word (.T. .F. .Y. .N. .AND. .OR. .NOT.) at p (p[0] == '.'). */
static int dot_word(lex *L) {
  const unsigned char *q = L->p + 1;
  unsigned char w[4]; int k = 0;
  while (q < L->end && is_alpha(*q) && k < 4) { w[k++] = (unsigned char)upper(*q); q++; }
  if (q >= L->end || *q != '.' || k == 0) return 0;
  q++;
  if (k == 1 && (w[0] == 'T' || w[0] == 'Y')) { L->tok = T_TRUE; L->p = q; return 1; }
  if (k == 1 && (w[0] == 'F' || w[0] == 'N')) { L->tok = T_FALSE; L->p = q; return 1; }
  if (k == 3 && w[0] == 'A' && w[1] == 'N' && w[2] == 'D') { L->tok = T_AND; L->p = q; return 1; }
  if (k == 2 && w[0] == 'O' && w[1] == 'R') { L->tok = T_OR; L->p = q; return 1; }
  if (k == 3 && w[0] == 'N' && w[1] == 'O' && w[2] == 'T') { L->tok = T_NOT; L->p = q; return 1; }
  return 0;
}

static void number(lex *L) {
  const unsigned char *q = L->p;
  int64_t iv = 0; double dv = 0.0; int dbl = 0, dec = 0, frac = 0;
  if (q + 1 < L->end && q[0] == '0' && (q[1] == 'x' || q[1] == 'X')) {
    q += 2;
    const unsigned char *h = q;
    while (q < L->end) {
      int c = *q, v;
      if (is_digit(c)) v = c - '0';
      else if (c >= 'a' && c <= 'f') v = c - 'a' + 10;
      else if (c >= 'A' && c <= 'F') v = c - 'A' + 10;
      else break;
      iv = (int64_t)((uint64_t)iv * 16u + (uint64_t)v);
      q++;
    }
    if(q==h){lex_fail(L,"Error BASE/1449  Syntax error: &");return;}
    L->num.kind = V_INT; L->num.i = iv; L->p = q; L->tok = T_NUM;
    return;
  }
  while (q < L->end) {
    int c = *q;
    if (is_digit(c)) {
      if (dbl) dv = dv * 10.0 + (c - '0');
      else if (iv < (INT64_MAX - 9) / 10) iv = iv * 10 + (c - '0');
      else { dv = (double)iv * 10.0 + (c - '0'); dbl = 1; }
      if (frac) dec++;
    } else if (c == '.' && !frac) {
      /* A dot must be followed by a digit (10. is a syntax error). */
      if (q + 1 >= L->end || !is_digit(q[1])) break;
      frac = 1;
    } else break;
    q++;
  }
  if (frac || dbl) {
    double v = dbl ? dv : (double)iv;
    if (dec) v /= pow10i(dec);
    L->num.kind = V_DBL; L->num.d = v; L->num.dec = dec;
  } else { L->num.kind = V_INT; L->num.i = iv; }
  L->p = q; L->tok = T_NUM;
}

static void next(lex *L) {
  while (L->p < L->end && is_space(*L->p)) L->p++;
  if (L->p >= L->end) { L->tok = T_END; return; }
  int c = *L->p;
  if (is_digit(c) || (c == '.' && L->p + 1 < L->end && is_digit(L->p[1]))) { number(L); return; }
  if (c == '.') { if (dot_word(L)) return; {lex_fail(L,"Error BASE/1449  Syntax error: &");return;} }
  if (c == '"' || c == '\'' || c == '[') {
    int close = c == '[' ? ']' : c;
    const unsigned char *q = L->p + 1;
    while (q < L->end && *q != close) q++;
    if (q >= L->end) {lex_fail(L,"Error BASE/1449  Syntax error: &");return;}
    L->ts = L->p + 1; L->tn = (size_t)(q - L->p - 1);
    L->p = q + 1; L->tok = T_STR; return;
  }
  if (is_alpha(c)) {
    const unsigned char *q = L->p;
    while (q < L->end && (is_alpha(*q) || is_digit(*q))) q++;
    L->ts = L->p; L->tn = (size_t)(q - L->p); L->p = q;
    if (L->tn == 3 && upper(L->ts[0]) == 'N' && upper(L->ts[1]) == 'I' && upper(L->ts[2]) == 'L') L->tok = T_NIL;
    else L->tok = T_IDENT;
    return;
  }
  const unsigned char *p = L->p;
  int c2 = p + 1 < L->end ? p[1] : 0;
  L->tok = T_OP; L->p++;
  switch (c) {
    case '(': L->tok = T_LPAREN; return;
    case ')': L->tok = T_RPAREN; return;
    case ',': L->tok = T_COMMA; return;
    case '&': L->tok = T_AMP; return;
    case ':':
      if (c2 == '=') {lex_fail(L,"Error: macro assignments are not in this increment (M0)");return;}
      {lex_fail(L,"Error BASE/1449  Syntax error: &");return;}
    case '{': {lex_fail(L,"Error: macro arrays, hashes and codeblocks are not in this increment (M0)");return;}
    /* ++ and -- are Harbour's increment/decrement operators; with no lvalue
     * in macro text they are a syntax error (--5 is not 5). */
    case '+': if (c2 == '+') { lex_fail(L, "Error BASE/1449  Syntax error: &"); return; } L->op = O_PLUS; return;
    case '-': if (c2 == '-') { lex_fail(L, "Error BASE/1449  Syntax error: &"); return; } L->op = O_MINUS; return;
    case '*': if (c2 == '*') { L->p++; L->op = O_POW; } else L->op = O_STAR; return;
    case '/': L->op = O_SLASH; return;
    case '%': L->op = O_PCT; return;
    case '^': L->op = O_POW; return;
    case '$': L->op = O_DOLLAR; return;
    case '#': L->op = O_NE; return;
    case '=': if (c2 == '=') { L->p++; L->op = O_EXEQ; } else L->op = O_EQ; return;
    case '!': if (c2 == '=') { L->p++; L->op = O_NE; } else L->op = O_BANG; return;
    case '<':
      if (c2 == '=') { L->p++; L->op = O_LE; }
      else if (c2 == '>') { L->p++; L->op = O_NE; }
      else L->op = O_LT;
      return;
    case '>': if (c2 == '=') { L->p++; L->op = O_GE; } else L->op = O_GT; return;
    default: {lex_fail(L,"Error BASE/1449  Syntax error: &");return;}
  }
}

static void drop(val *v) { if (v->kind == V_STR && v->owned) { hrm_free((unsigned char *)v->s); v->owned = 0; } }

static val mkerr2(const char *pre, const unsigned char *name, size_t n) {
  val r = {0};
  r.kind = V_ERR;
  size_t k = 0;
  for (size_t j = 0; pre[j] && k < sizeof r.ebuf - 2; j++) r.ebuf[k++] = (unsigned char)pre[j];
  for (size_t j = 0; j < n && k < sizeof r.ebuf - 2; j++) r.ebuf[k++] = (unsigned char)upper(name[j]);
  r.ebuf[k++] = '\n';
  r.en = k;
  return r;
}
static val mkerr(const char *m) { return mkerr2(m, 0, 0); }

static val arg_err(int op) {
  switch (op) {
    case O_PLUS: return mkerr("Error BASE/1081  Argument error: +");
    case O_MINUS: return mkerr("Error BASE/1082  Argument error: -");
    case O_STAR: return mkerr("Error BASE/1083  Argument error: *");
    case O_SLASH: return mkerr("Error BASE/1084  Argument error: /");
    case O_PCT: return mkerr("Error BASE/1085  Argument error: %");
    case O_POW: return mkerr("Error BASE/1088  Argument error: ^");
    case O_EXEQ: return mkerr("Error BASE/1070  Argument error: ==");
    case O_EQ: return mkerr("Error BASE/1071  Argument error: =");
    case O_NE: return mkerr("Error BASE/1072  Argument error: <>");
    case O_LT: return mkerr("Error BASE/1073  Argument error: <");
    case O_LE: return mkerr("Error BASE/1074  Argument error: <=");
    case O_GT: return mkerr("Error BASE/1075  Argument error: >");
    case O_GE: return mkerr("Error BASE/1076  Argument error: >=");
    default: return mkerr("Error BASE/1109  Argument error: $");
  }
}

static int is_num(const val *v) { return v->kind == V_INT || v->kind == V_DBL; }
static double as_d(const val *v) { return v->kind == V_INT ? (double)v->i : v->d; }
/* DEF_DEC is Harbour's default-decimals marker (HB_DEFAULT_DECIMALS): the
 * results of / % ^ carry it, it wins in any later + - *, and it prints as
 * SET DECIMALS (2). (14 ^ 3) * 3.55 is 9741.20, not 9741.2000. */
#define DEF_DEC (-1)
static int dec_of(const val *v) { return v->kind == V_DBL ? v->dec : 0; }
static int dec_max(const val *a, const val *b) {
  int x = dec_of(a), y = dec_of(b);
  if (x == DEF_DEC || y == DEF_DEC) return DEF_DEC;
  return x > y ? x : y;
}
static int dec_sum(const val *a, const val *b) {
  int x = dec_of(a), y = dec_of(b);
  if (x == DEF_DEC || y == DEF_DEC) return DEF_DEC;
  return x + y;
}
static val mkdbl(double d, int dec) { val r = {0}; r.kind = V_DBL; r.d = d; r.dec = dec; r.meta=(((uint64_t)((d>9999999999.0||d< -999999999.0)?20:10))<<16)|(unsigned)(dec == DEF_DEC ? 2 : dec); return r; }
static val mkint(int64_t i) { val r = {0}; r.kind = V_INT; r.i = i; return r; }
static val mklog(int b) { val r = {0}; r.kind = V_LOG; r.i = b ? 1 : 0; return r; }

static double trunc_d(double x) {
  if (x >= 9.2e18 || x <= -9.2e18 || x != x) return x;
  return (double)(int64_t)x;
}

static val concat(val *a, val *b, int minus) {
  size_t n = a->n + b->n, k = 0, keep = a->n, trail = 0;
  unsigned char *o;
  if(n<a->n){drop(a);drop(b);return mkerr("Error: macro allocation size limit (M0)");}
  o=hrm_alloc(n);if(!o){drop(a);drop(b);return mkerr("Error: macro allocation failure (M0)");}
  if (minus) { while (keep > 0 && a->s[keep - 1] == ' ') { keep--; trail++; } }
  for (size_t j = 0; j < keep; j++) o[k++] = a->s[j];
  for (size_t j = 0; j < b->n; j++) o[k++] = b->s[j];
  for (size_t j = 0; j < trail; j++) o[k++] = ' ';
  drop(a); drop(b);
  val r = {0}; r.kind = V_STR; r.s = o; r.n = n; r.owned = 1;
  return r;
}

/* Harbour hb_itemStrCmp with SET EXACT OFF (exact: == semantics). */
static int strcmp_h(const val *a, const val *b, int exact) {
  size_t m = a->n < b->n ? a->n : b->n;
  for (size_t j = 0; j < m; j++) {
    if (a->s[j] != b->s[j]) return a->s[j] < b->s[j] ? -1 : 1;
  }
  if (a->n == b->n) return 0;
  if (!exact && a->n > b->n) return 0;
  return a->n < b->n ? -1 : 1;
}

/* First deferred error wins; the other operand is released. */
static int pending(val *a, val *b, val *out) {
  if (a->kind == V_ERR) { drop(b); *out = *a; return 1; }
  if (b->kind == V_ERR) { drop(a); *out = *b; return 1; }
  return 0;
}

static val compare(int op, val *a, val *b) {
  int r = 0;
  val e;
  if (pending(a, b, &e)) return e;
  if (a->kind == V_NIL || b->kind == V_NIL) {
    if (op == O_EQ || op == O_EXEQ || op == O_NE) {
      int same = a->kind == V_NIL && b->kind == V_NIL;
      drop(a); drop(b);
      return mklog(op == O_NE ? !same : same);
    }
    drop(a); drop(b);
    return arg_err(op);
  }
  if (is_num(a) && is_num(b)) {
    if (a->kind == V_INT && b->kind == V_INT) r = a->i < b->i ? -1 : a->i > b->i;
    else { double x = as_d(a), y = as_d(b); r = x < y ? -1 : x > y; }
  } else if (a->kind == V_STR && b->kind == V_STR) {
    r = strcmp_h(a, b, op == O_EXEQ);
  } else if (a->kind == V_LOG && b->kind == V_LOG) {
    r = (int)(a->i - b->i);
  } else { drop(a); drop(b); return arg_err(op); }
  drop(a); drop(b);
  switch (op) {
    case O_EQ: case O_EXEQ: return mklog(r == 0);
    case O_NE: return mklog(r != 0);
    case O_LT: return mklog(r < 0);
    case O_LE: return mklog(r <= 0);
    case O_GT: return mklog(r > 0);
    default: return mklog(r >= 0);
  }
}

/* x^k for integer k >= 0 in double-double arithmetic (Dekker products,
 * about 106 bits), rounded to double once. Harbour calls the C runtime pow;
 * repeated double products drift in the 16th digit. */
static void two_prod(double a, double b, double *p, double *e) {
  const double split = 134217729.0; /* 2^27 + 1 */
  double t = split * a, ah = t - (t - a), al = a - ah;
  t = split * b;
  double bh = t - (t - b), bl = b - bh;
  *p = a * b;
  *e = ((ah * bh - *p) + ah * bl + al * bh) + al * bl;
}
static void dd_mul(double ah, double al, double bh, double bl, double *rh, double *rl) {
  double p, e;
  two_prod(ah, bh, &p, &e);
  e += ah * bl + al * bh;
  double s = p + e;
  *rl = e - (s - p);
  *rh = s;
}
static double pow_int(double x, int64_t k) {
  double rh = 1.0, rl = 0.0, bh = x, bl = 0.0;
  while (k) {
    if (k & 1) dd_mul(rh, rl, bh, bl, &rh, &rl);
    k >>= 1;
    if (k) dd_mul(bh, bl, bh, bl, &bh, &bl);
  }
  return rh + rl;
}

/* folding = 1: Harbour's compile-time constant folding (both operands are
 * literals); folding = 0: run-time operators. Run-time / and % always give
 * a default-decimals double (memvar x := 10: x % 3 is 1.00, x / 2 is 5.00);
 * a zero divisor is never folded (see fold) and yields the integer 0. */
static val arith(int op, val *a, val *b, int folding) {
  val e;
  if (pending(a, b, &e)) return e;
  if (op == O_PLUS && a->kind == V_STR && b->kind == V_STR) return concat(a, b, 0);
  if (op == O_MINUS && a->kind == V_STR && b->kind == V_STR) return concat(a, b, 1);
  if (!is_num(a) || !is_num(b)) { drop(a); drop(b); return arg_err(op); }
  int ints = a->kind == V_INT && b->kind == V_INT;
  int64_t r;
  switch (op) {
    case O_PLUS:
      if (ints && !__builtin_add_overflow(a->i, b->i, &r)) return mkint(r);
      return mkdbl(as_d(a) + as_d(b), dec_max(a, b));
    case O_MINUS:
      if (ints && !__builtin_sub_overflow(a->i, b->i, &r)) return mkint(r);
      return mkdbl(as_d(a) - as_d(b), dec_max(a, b));
    case O_STAR:
      if (ints && !__builtin_mul_overflow(a->i, b->i, &r)) return mkint(r);
      return mkdbl(as_d(a) * as_d(b), dec_sum(a, b));
    case O_SLASH: {
      if (as_d(b) == 0.0) return mkint(0);
      if (folding && ints && !(a->i == INT64_MIN && b->i == -1) && a->i % b->i == 0) return mkint(a->i / b->i);
      return mkdbl(as_d(a) / as_d(b), DEF_DEC);
    }
    case O_PCT: {
      if (as_d(b) == 0.0) return mkint(0);
      if (folding && ints) return mkint(b->i == -1 ? 0 : a->i % b->i);
      return mkdbl(hrm_fmod(as_d(a), as_d(b)), DEF_DEC);
    }
    default: { /* O_POW */
      double x = as_d(a), y = as_d(b), p;
      if (y == trunc_d(y) && y >= -1024.0 && y <= 1024.0) {
        int64_t k = (int64_t)y; int neg = k < 0; if (neg) k = -k;
        p = pow_int(x, k);
        if (neg) p = 1.0 / p;
      } else if (x > 0.0) p = hrm_powf(x, y);
      else if (x == 0.0) p = y > 0.0 ? 0.0 : 1.0 / x;
      else p = hrm_exp(y * hrm_log(x)); /* negative base, fractional power: NaN */
      return mkdbl(p, DEF_DEC);
    }
  }
}

/* Parse owns nodes, but performs no binding lookup and calls no fatal route. */
enum { N_VALUE,N_LOOKUP,N_UNARY,N_BINARY,N_AND,N_OR,N_LIST,N_MACRO,N_CALL,N_ARGUMENT };
typedef struct node {
 struct node *allocated,*a,*b;
 int kind,op;
 val value;
 const unsigned char *name; size_t len;
} node;
typedef struct {
 lex L; hrmacro_context *ctx; node *allocated; size_t count;unsigned depth;
 node emergency;
} parser;
static node *parse_or(parser*);
static void parse_bad(parser*p){lex_fail(&p->L,"Error BASE/1449  Syntax error: &");}
static node *newnode(parser*p,int kind,node*a,node*b){
 node*n;
 if(p->count>=4096){lex_fail(&p->L,"Error: macro node budget limit (M0)");return &p->emergency;}
 n=p->ctx->bridge.storage.alloc(p->ctx->bridge.storage.user,sizeof(*n));
 if(!n){lex_fail(&p->L,"Error: macro allocation failure (M0)");return &p->emergency;}
 *n=(node){0};n->kind=kind;n->a=a;n->b=b;n->allocated=p->allocated;p->allocated=n;p->count++;p->ctx->scratch_live++;return n;
}
static node *binary(parser*p,int kind,int op,node*a,node*b){node*n=newnode(p,kind,a,b);n->op=op;return n;}
static node *primary(parser*p){
 lex*L=&p->L;node*n;
 if(++p->depth>128){lex_fail(L,"Error: macro nesting limit (M0)");p->depth--;return &p->emergency;}
 switch(L->tok){
 case T_NUM:n=newnode(p,N_VALUE,0,0);n->value=L->num;n->value.literal=1;next(L);break;
 case T_STR:n=newnode(p,N_VALUE,0,0);n->value.kind=V_STR;n->value.s=L->ts;n->value.n=L->tn;n->value.literal=1;next(L);break;
 case T_TRUE:case T_FALSE:n=newnode(p,N_VALUE,0,0);n->value=mklog(L->tok==T_TRUE);n->value.literal=1;next(L);break;
 case T_NIL:n=newnode(p,N_VALUE,0,0);n->value.literal=1;next(L);break;
 case T_LPAREN:
  next(L);n=parse_or(p);
  while(L->tok==T_COMMA&&!L->error){next(L);n=binary(p,N_LIST,0,n,parse_or(p));}
  if(L->tok!=T_RPAREN)parse_bad(p);else next(L);break;
 case T_AMP:
  next(L);
  if(L->tok==T_IDENT){node*x=newnode(p,N_LOOKUP,0,0);x->name=L->ts;x->len=L->tn;next(L);n=newnode(p,N_MACRO,x,0);break;}
  if(L->tok!=T_LPAREN){parse_bad(p);n=&p->emergency;break;}
  next(L);n=newnode(p,N_MACRO,parse_or(p),0);
  if(L->tok!=T_RPAREN)parse_bad(p);else next(L);break;
 case T_IDENT:{
  const unsigned char*s=L->ts;size_t len=L->tn;
  /* Explicit M-> is MEMVAR-only, never a field fallback. */
  const unsigned char*q=L->p;while(q<L->end&&is_space(*q))q++;
  if(len==1&&upper(s[0])=='M'&&q+1<L->end&&q[0]=='-'&&q[1]=='>'){
   L->p=q+2;next(L);if(L->tok!=T_IDENT){parse_bad(p);n=&p->emergency;break;}s=L->ts;len=L->tn;
  }
  next(L);n=newnode(p,N_LOOKUP,0,0);n->name=s;n->len=len;
  if(L->tok==T_LPAREN){
   n->kind=N_CALL;next(L);node*args=0,**tail=&args;
   if(L->tok!=T_RPAREN){for(;;){node*x=parse_or(p);node*arg=newnode(p,N_ARGUMENT,x,0);*tail=arg;tail=&arg->b;if(L->tok!=T_COMMA||L->error)break;next(L);}}
   n->a=args;if(L->tok!=T_RPAREN)parse_bad(p);else next(L);
  }
  break;}
 default:parse_bad(p);n=&p->emergency;break;
 }
 p->depth--;return n;
}
static node *negation(parser*p);
static node *unary(parser*p){
 /* .NOT. / ! may also start an operand (x / .NOT. y): as in Harbour's
  * grammar it then takes a negation-level operand. */
 if(p->L.tok==T_NOT||(p->L.tok==T_OP&&p->L.op==O_BANG))return negation(p);
 if(p->L.tok==T_OP&&(p->L.op==O_MINUS||p->L.op==O_PLUS)){
  int op=p->L.op;next(&p->L);
  if(++p->depth>128){lex_fail(&p->L,"Error: macro nesting limit (M0)");p->depth--;return &p->emergency;}
  node*n=binary(p,N_UNARY,op,unary(p),0);p->depth--;return n;
 }
 return primary(p);
}
static node *power(parser*p){node*a=unary(p);while(p->L.tok==T_OP&&p->L.op==O_POW&&!p->L.error){next(&p->L);a=binary(p,N_BINARY,O_POW,a,unary(p));}return a;}
static node *term(parser*p){node*a=power(p);while(p->L.tok==T_OP&&(p->L.op==O_STAR||p->L.op==O_SLASH||p->L.op==O_PCT)&&!p->L.error){int op=p->L.op;next(&p->L);a=binary(p,N_BINARY,op,a,power(p));}return a;}
static node *sum(parser*p){node*a=term(p);while(p->L.tok==T_OP&&(p->L.op==O_PLUS||p->L.op==O_MINUS)&&!p->L.error){int op=p->L.op;next(&p->L);a=binary(p,N_BINARY,op,a,term(p));}return a;}
/* Harbour puts equality (= == != <> #) one level BELOW the ordering
 * operators (< <= > >= $); both are left-associative. .T. != x $ y runs $
 * first, which decides the first error raised. */
static int is_ordering(int op){return op==O_LT||op==O_LE||op==O_GT||op==O_GE||op==O_DOLLAR;}
static node *comparison(parser*p){node*a=sum(p);while(p->L.tok==T_OP&&is_ordering(p->L.op)&&!p->L.error){int op=p->L.op;next(&p->L);a=binary(p,N_BINARY,op,a,sum(p));}return a;}
static node *relation(parser*p){node*a=comparison(p);while(p->L.tok==T_OP&&(p->L.op==O_EQ||p->L.op==O_EXEQ||p->L.op==O_NE)&&!p->L.error){int op=p->L.op;next(&p->L);a=binary(p,N_BINARY,op,a,comparison(p));}return a;}
static node *negation(parser*p){if(p->L.tok==T_NOT||(p->L.tok==T_OP&&p->L.op==O_BANG)){next(&p->L);if(++p->depth>128){lex_fail(&p->L,"Error: macro nesting limit (M0)");p->depth--;return &p->emergency;}node*n=binary(p,N_UNARY,O_BANG,negation(p),0);p->depth--;return n;}return relation(p);}
static node *parse_and(parser*p){node*a=negation(p);while(p->L.tok==T_AND&&!p->L.error){next(&p->L);a=binary(p,N_AND,0,a,negation(p));}return a;}
static node *parse_or(parser*p){node*a=parse_and(p);while(p->L.tok==T_OR&&!p->L.error){next(&p->L);a=binary(p,N_OR,0,a,parse_and(p));}return a;}
static val borrow(val v){v.owned=0;return v;}
static val unary_value(int op,val v){
 if(v.kind==V_ERR)return v;
 if(op==O_BANG){if(v.kind!=V_LOG){drop(&v);return mkerr("Error BASE/1077  Argument error: .NOT.");}v.i=!v.i;return v;}
 if(op==O_PLUS)return v;
 if(v.kind==V_INT){if(v.i==INT64_MIN)return mkdbl(-(double)v.i,0);v.i=-v.i;return v;}
 if(v.kind==V_DBL){v.d=-v.d;return v;}drop(&v);return mkerr("Error BASE/1080  Argument error: -");
}
static val binary_value(int op,val a,val b,int folding){
 if(op>=O_EQ&&op<=O_GE)return compare(op,&a,&b);
 if(op==O_DOLLAR){val e;if(pending(&a,&b,&e))return e;if(a.kind!=V_STR||b.kind!=V_STR){drop(&a);drop(&b);return arg_err(op);}int found=0;if(a.n>0&&a.n<=b.n){for(size_t j=0;j+a.n<=b.n&&!found;j++){size_t k=0;while(k<a.n&&b.s[j+k]==a.s[k])k++;found=k==a.n;}}drop(&a);drop(&b);return mklog(found);}
 return arith(op,&a,&b,folding);
}
/* No lookup is possible in this pass. Only literal-source values are cached.
 * Boolean constant elimination is allowed with an unresolved other subtree. */
static int builtin_id(const unsigned char*s,size_t n){
 static const char names[][6]={"UPPER","LOWER","ROUND"};
 for(int id=1;id<=3;id++){const char*t=names[id-1];size_t j=0;while(j<n&&t[j]&&upper(s[j])==t[j])j++;if(j==n&&!t[j])return id;}
 return 0;
}
static val call_error(int id){val v=mkerr(id==1?"Error BASE/1102  Argument error: UPPER":id==2?"Error BASE/1103  Argument error: LOWER":"Error BASE/1094  Argument error: ROUND");v.builtin=id==1?"UPPER":id==2?"LOWER":"ROUND";return v;}
static node *fold(node*n){
 if(!n)return n;
 n->a=fold(n->a);n->b=fold(n->b);
 if(n->kind==N_CALL){
  size_t argc=0;for(node*q=n->a;q;q=q->b)argc++;
  int id=builtin_id(n->name,n->len);node*first=argc<=64&&n->a?n->a->a:0;
  if((id==1||id==2)&&first&&first->kind==N_VALUE&&first->value.literal&&first->value.kind==V_STR){
   val v=borrow(first->value);unsigned char*out=hrm_alloc(v.n);
   if(!out)n->value=mkerr("Error: macro allocation failure (M2)");
   else{for(size_t j=0;j<v.n;j++){unsigned char c=v.s[j];out[j]=(id==1)?(unsigned char)upper(c):(c>='A'&&c<='Z'?c+32:c);}n->value=v;n->value.s=out;n->value.owned=1;}
   n->value.literal=1;n->kind=N_VALUE;
  }
 }
 if(n->kind==N_AND||n->kind==N_OR){
  int a=n->a->kind==N_VALUE&&n->a->value.kind==V_LOG;
  int b=n->b->kind==N_VALUE&&n->b->value.kind==V_LOG;
  if(a){if(n->kind==N_AND?!n->a->value.i:n->a->value.i)return n->a;return n->b;}
  if(b){if(n->kind==N_AND?n->b->value.i:!n->b->value.i)return n->a;return n->b;}
 }
 if(n->kind==N_UNARY&&n->a->kind==N_VALUE){n->value=unary_value(n->op,borrow(n->a->value));n->value.literal=1;n->kind=N_VALUE;}
 else if(n->kind==N_BINARY&&n->a->kind==N_VALUE&&n->b->kind==N_VALUE
         /* A division or % by zero is not folded: it runs at run time (the
          * default recovery gives 0) and what is computed from it follows the
          * run-time rules - 5 % 0 % 1 is 0.00 while the constant 0 % 1 is 0. */
         &&!((n->op==O_SLASH||n->op==O_PCT)&&is_num(&n->b->value)&&as_d(&n->b->value)==0.0)){n->value=binary_value(n->op,borrow(n->a->value),borrow(n->b->value),1);n->value.literal=1;n->kind=N_VALUE;}
 return n;
}
static val status_error(hrmv_status rc,const unsigned char*s,size_t len){
 switch(rc){
 case HRMV_UNDEFINED:return mkerr2("Error BASE/1003  Variable does not exist: ",s,len);
 case HRMV_TYPE_UNSUPPORTED:return mkerr("Error: unsupported MEMVAR value representation (M0)");
 case HRMV_BAD_NAME:return mkerr("Error: MEMVAR names are ASCII-only in M0");
 case HRMV_MEMORY:return mkerr("Error: MEMVAR allocation failure (M0)");
 case HRMV_BAD_FRAME:return mkerr("Error: MEMVAR frame mismatch (M0)");
 default:return mkerr("Error: MEMVAR context/size limit (M0)");
 }
}
extern void hrm_builtin_fail(const unsigned char*,size_t,const unsigned char*,size_t) __attribute__((noreturn));
static void program_fatal(void*,const unsigned char*,size_t);
static val eval_text(hrmacro_context*,const unsigned char*,size_t,unsigned);
extern unsigned hrm_call(unsigned,size_t,const hrm_cell*,hrm_cell*);
static val evaluate(hrmacro_context*,node*,unsigned);
static void call_cell_drop(hrm_cell*v){if((v->tag&255u)==4||(v->tag&255u)==5)hrm_free((unsigned char*)(uintptr_t)v->payload);v->tag=1;v->payload=0;}
static val evaluate_call(hrmacro_context*c,node*n,unsigned nesting){
 size_t count=0,used=0;node*arg=n->a;int id=builtin_id(n->name,n->len);val v={0};hrm_cell out={1,0};hrm_cell*argv=0;
 for(node*q=arg;q;q=q->b)count++;
 if(count>64)return mkerr("Error: macro call arity exceeds 64 (M2)");
 if(count){argv=c->bridge.storage.alloc(c->bridge.storage.user,count*sizeof(*argv));if(!argv)return mkerr("Error: macro allocation failure (M2)");c->scratch_live++;}
 for(;arg;arg=arg->b){
  v=evaluate(c,arg->a,nesting);if(v.kind==V_ERR)goto done;
  hrm_cell cell={1,0};hrmv_status rc=HRMV_OK;
  switch(v.kind){
   case V_INT:cell.tag=0;cell.payload=(uint64_t)v.i;break;
   case V_LOG:cell.tag=3;cell.payload=(uint64_t)v.i;break;
   case V_DBL:{union{uint64_t u;double d;}x;x.d=v.d;rc=c->bridge.float_new(c->bridge.compiler_user,x.u,v.meta,&cell);break;}
   case V_STR:
    cell.tag=4;if(v.owned){cell.payload=(uint64_t)(uintptr_t)v.s;v.owned=0;}
    else{unsigned char*o=hrm_alloc(v.n);if(!o)rc=HRMV_MEMORY;else{for(size_t j=0;j<v.n;j++)o[j]=v.s[j];cell.payload=(uint64_t)(uintptr_t)o;}}break;
   default:break;
  }
  drop(&v);if(rc!=HRMV_OK){v=status_error(rc,0,0);goto done;}argv[used++]=cell;
 }
 if(!id){v=mkerr2("Error: macro function not supported (M2): ",n->name,n->len);goto done;}
 if((id<=2&&(!count||(argv[0].tag&255u)!=4))||(id==3&&(count<2||((argv[0].tag&255u)!=0&&(argv[0].tag&255u)!=5)||((argv[1].tag&255u)!=0&&(argv[1].tag&255u)!=5)))){v=call_error(id);goto done;}
 if(id==3){
  double d;if((argv[1].tag&255u)==5)d=*(const double*)(uintptr_t)argv[1].payload;else d=(double)(int64_t)argv[1].payload;
  /* Validate before integer conversion or production helper's legacy fatal. */
  if(!(d>-16.0&&d<16.0)){v=mkerr("Error: macro ROUND decimals outside -15..15 (M2)");goto done;}
 }
 if(!hrm_call((unsigned)id,count,argv,&out)){v=mkerr("Error: macro builtin dispatch failure (M2)");goto done;}
 v=(val){0};switch(out.tag&255u){
  case 0:case 9:v=mkint((int64_t)out.payload);break;
  case 1:break;
  case 3:v=mklog(out.payload!=0);break;
  case 4:v.kind=V_STR;v.s=(const unsigned char*)(uintptr_t)out.payload;v.n=((const uint64_t*)v.s)[-1];v.owned=1;out.tag=1;break;
  case 5:{const uint64_t*f=(const uint64_t*)(uintptr_t)out.payload;union{uint64_t u;double d;}x;x.u=f[0];v=mkdbl(x.d,(int)(f[1]&65535u));v.meta=f[1];break;}
  default:v=mkerr("Error: macro builtin result type unsupported (M2)");break;
 }
 call_cell_drop(&out);
 done:
 while(used)call_cell_drop(&argv[--used]);
 if(argv){c->bridge.storage.free(c->bridge.storage.user,argv,count*sizeof(*argv));c->scratch_live--;}
 return v;
}
static val evaluate(hrmacro_context*c,node*n,unsigned nesting){
 val a,b;hrm_cell cell;hrmv_status rc;
 if(n->kind==N_VALUE)return borrow(n->value);
 if(n->kind==N_LOOKUP){
  c->lookups++;rc=hrmb_get_copy(&c->bridge,(const char*)n->name,n->len,&cell);if(rc!=HRMV_OK)return status_error(rc,n->name,n->len);
  a=(val){0}; /* tag9 read from a binding is NEVER a source literal. */
  switch(cell.tag&255u){
  case 0:case 9:a.kind=V_INT;a.i=(int64_t)cell.payload;break;
  case 1:a.kind=V_NIL;break;
  case 3:a=mklog(cell.payload!=0);break;
  case 4:a.kind=V_STR;a.s=(const unsigned char*)(uintptr_t)cell.payload;a.n=((const uint64_t*)a.s)[-1];a.owned=1;break;
  case 5:{const uint64_t*p=(const uint64_t*)(uintptr_t)cell.payload;union{uint64_t u;double d;}x;x.u=p[0];a=mkdbl(x.d,(int)(p[1]&65535u));a.meta=p[1];hrm_free((unsigned char*)(uintptr_t)cell.payload);break;}
  default:return status_error(HRMV_TYPE_UNSUPPORTED,n->name,n->len);
  }return a;
 }
 if(n->kind==N_CALL)return evaluate_call(c,n,nesting);
 a=evaluate(c,n->a,nesting);if(n->kind==N_UNARY)return unary_value(n->op,a);
 if(n->kind==N_MACRO){
  if(a.kind==V_ERR)return a;
  if(a.kind!=V_STR){drop(&a);return mkerr("Error BASE/1449  Syntax error: &");}
  if(nesting>=64){drop(&a);return mkerr("Error: nested macro limit (M0)");}
  b=eval_text(c,a.s,a.n,nesting+1);drop(&a);return b;
 }
 if(n->kind==N_LIST){if(a.kind==V_ERR)return a;drop(&a);return evaluate(c,n->b,nesting);}
 if(n->kind==N_AND||n->kind==N_OR){
  if(a.kind==V_ERR)return a;
  /* Harbour compiles .AND./.OR. as conditional jumps: a non-logical left
   * operand is BASE/1066 "conditional"; the right operand is the result,
   * unchecked (folding already handled constant logicals). */
  if(a.kind!=V_LOG){drop(&a);return mkerr("Error BASE/1066  Argument error: conditional");}
  if(n->kind==N_AND?!a.i:a.i)return a;
  return evaluate(c,n->b,nesting);
 }
 /* Left surviving error wins without resolving later runtime names. */
 if(a.kind==V_ERR)return a;
 b=evaluate(c,n->b,nesting);return binary_value(n->op,a,b,0);
}
static val eval_text(hrmacro_context*c,const unsigned char*src,size_t len,unsigned nesting){
 parser p={0};val v;p.ctx=c;p.L.p=src;p.L.end=src+len;p.emergency.kind=N_VALUE;p.emergency.value=mkerr("Error: macro allocation failure (M0)");
 if(len>65536)return mkerr("Error: macro text byte budget limit (M0)");
 next(&p.L);node*n=parse_or(&p);if(p.L.tok!=T_END&&!p.L.error)parse_bad(&p);
 if(p.L.error)v=mkerr(p.L.message);else{n=fold(n);v=evaluate(c,n,nesting);}
 /* Borrowed cache/source string must be copied before the parser dies. */
 if(v.kind==V_STR&&!v.owned){unsigned char*o=hrm_alloc(v.n);if(!o)v=mkerr("Error: macro allocation failure (M0)");else{for(size_t j=0;j<v.n;j++)o[j]=v.s[j];v.s=o;v.owned=1;}}
 while(p.allocated){node*q=p.allocated;p.allocated=q->allocated;drop(&q->value);c->bridge.storage.free(c->bridge.storage.user,q,sizeof(*q));c->scratch_live--;}
 return v;
}
hrmv_status hrmacro_init(hrmacro_context*c,hrmv_alloc_fn a,hrmv_free_fn f,void*raw,hrmb_string_fn s,hrmb_float_fn d,void*compiler,hrmacro_fatal_fn fatal,void*user){
 if(!c||!fatal)return HRMV_BAD_ARGUMENT;hrmv_status rc=hrmb_init(&c->bridge,a,f,raw,s,d,compiler);if(rc)return rc;c->fatal=fatal;c->fatal_user=user;c->scratch_live=0;c->lookups=0;return HRMV_OK;
}
void hrmacro_destroy(hrmacro_context*c){if(c)hrmb_destroy(&c->bridge);}
hrm_cell hrmacro_eval(hrmacro_context*c,const unsigned char*src,size_t len){
 val v=eval_text(c,src,len,0);hrm_cell out={1,0};hrmv_status rc=HRMV_OK;
 switch(v.kind){
 case V_INT:out.tag=v.literal?9:0;out.payload=(uint64_t)v.i;break;
 case V_LOG:out.tag=3;out.payload=(uint64_t)v.i;break;
 case V_NIL:break;
 case V_STR:out.tag=4;out.payload=(uint64_t)(uintptr_t)v.s;v.owned=0;break;
 case V_DBL:{union{double d;uint64_t u;}x;x.d=v.d;uint64_t meta=v.meta;if(!meta)meta=(10u<<16)|(unsigned)v.dec;rc=c->bridge.float_new(c->bridge.compiler_user,x.u,meta,&out);break;}
 default:break;
 }
 if(rc!=HRMV_OK)v=status_error(rc,0,0);
 if(v.kind==V_ERR){
  /* Terminal M0 only: no ErrorBlock/BREAK/RECOVER claim. All evaluator
   * temporaries and every context/frame binding die before host fatal. */
  drop(&v);hrmacro_destroy(c);
  if(v.builtin&&c->fatal==program_fatal){size_t len=0;while(v.builtin[len])len++;hrm_builtin_fail(v.ebuf,v.en,(const unsigned char*)v.builtin,len);}
  c->fatal(c->fatal_user,v.ebuf,v.en);
  /* A fatal host callback is contractually noreturn. Fail closed if broken. */
  for(;;){}
 }
 drop(&v);return out;
}
/* Generated-program adapters remain internal SysV, same as this unit. */
extern void *hrm_raw_alloc(void*,size_t);
extern void hrm_raw_free(void*,void*,size_t);
extern hrmv_status hrm_export_string(void*,const unsigned char*,size_t,hrv_cell*);
extern hrmv_status hrm_export_float(void*,uint64_t,uint64_t,hrv_cell*);
extern void hrm_builtin_fail(const unsigned char*,size_t,const unsigned char*,size_t) __attribute__((noreturn));
static void program_fatal(void*u,const unsigned char*s,size_t n){(void)u;hrm_fail(s,n);}
/* Root owns this object on its stack. No storage singleton exists. */
void hrmacro_start(hrmacro_context*c){
 typedef char context_must_fit_root_slot[(sizeof(hrmacro_context)<=256)?1:-1];(void)sizeof(context_must_fit_root_slot);
 hrmv_status rc=hrmacro_init(c,hrm_raw_alloc,hrm_raw_free,0,hrm_export_string,hrm_export_float,0,program_fatal,0);
 if(rc){static const unsigned char msg[]="Error: MEMVAR context initialization failure (M0)\n";hrm_fail(msg,sizeof(msg)-1);}
 /* HARBOUR/CLIPPER do NOT exist before PUBLIC declaration in the oracle. */
}
static void raise_status(hrmacro_context*c,hrmv_status rc,const unsigned char*s,size_t n){if(rc){val v=status_error(rc,s,n);hrmacro_destroy(c);c->fatal(c->fatal_user,v.ebuf,v.en);for(;;){}}}
uint64_t hrmacro_enter(hrmacro_context*c){uint64_t mark=0;raise_status(c,hrmb_frame_enter(&c->bridge,&mark),0,0);return mark;}
void hrmacro_leave(hrmacro_context*c,uint64_t mark){raise_status(c,hrmb_frame_leave(&c->bridge,mark),0,0);}
void hrmacro_declare(hrmacro_context*c,int priv,const unsigned char*s,size_t n){raise_status(c,hrmb_declare(&c->bridge,priv,(const char*)s,n),s,n);}
void hrmacro_put(hrmacro_context*c,const unsigned char*s,size_t n,uint64_t tag,uint64_t payload){hrv_cell v={tag,payload};raise_status(c,hrmv_put_copy(&c->bridge.storage,(const char*)s,n,v),s,n);}
hrm_cell hrmacro_lookup(hrmacro_context*c,const unsigned char*s,size_t n){hrv_cell v={1,0};raise_status(c,hrmb_get_copy(&c->bridge,(const char*)s,n,&v),s,n);if(v.tag==9)v.tag=0;return v;}
void hrmacro_str_check(hrmacro_context*c,uint64_t tag,uint64_t payload,int owned){
 unsigned kind=(unsigned)(tag&255u);if(kind==0||kind==9||kind==5)return;
 if(owned&&kind==4)hrm_free((unsigned char*)(uintptr_t)payload);
 val v=mkerr("Error BASE/1099  Argument error: STR");hrmacro_destroy(c);
 if(c->fatal==program_fatal)hrm_builtin_fail(v.ebuf,v.en,(const unsigned char*)"STR",3);
 c->fatal(c->fatal_user,v.ebuf,v.en);for(;;){}
}
uint64_t hrmacro_exists(hrmacro_context*c,const unsigned char*s,size_t n){int yes=0;raise_status(c,hrmv_exists(&c->bridge.storage,(const char*)s,n,&yes),s,n);return (uint64_t)yes;}
