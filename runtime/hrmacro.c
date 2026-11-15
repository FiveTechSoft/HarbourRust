/* Own MIT. Runtime macro evaluator (M1): `&(expr)` / `&name` over constant
 * Harbour expressions. Freestanding C, no libc, compiled ahead of time to
 * generated/hrmacro.s with the SysV ABI (the hbc-internal convention on
 * every x86-64 target), so the same assembly serves ELF, PE and Mach-O.
 *
 * Semantics are Harbour 3.2.0's macro compiler, measured (docs/
 * MACRO-M1-2026-11-15.md). Because every operand is a literal, Harbour
 * constant-folds the expression (expropt2.c) before running it; the rules
 * below are those folding rules, not the runtime operator rules:
 *   int + - * int stays int (overflow becomes double); doubles take
 *   max(dec) for + - and dec1 + dec2 for *; / is int when exact between
 *   ints, otherwise a double with 2 decimals; any division or % by zero
 *   is the integer 0; % keeps the dividend's sign (int, or double with
 *   2 decimals); ^ and ** are left-associative doubles with 2 decimals;
 *   unary minus binds tighter than ^; .AND./.OR. fold against a logical
 *   constant on either side and return the other operand unchanged.
 * Identifiers are memvars/fields in Harbour. hbc has neither, so a bare
 * name is Harbour's own BASE/1003 error; LOCALs are invisible to macros
 * in Harbour too. Function calls are the named M2 limit.
 *
 * Values cross into hbc as the 16-byte Dyn cell: kind 9 literal int, 1 NIL,
 * 3 logical, 4 owned string (hbc_stralloc data pointer), 5 heap float
 * (hbc_float_new). All allocation goes through the hrm_* shims, which
 * preserve every SysV callee-saved register around the hbc helpers. */
/* No system headers: the SysV build runs on a MinGW host whose headers
 * assume the Win64 ABI. Fixed-width types are spelled out (LP64 and LLP64
 * agree on long long and pointers). */
typedef unsigned long long uint64_t;
typedef long long int64_t;
typedef unsigned long long size_t;
typedef unsigned long long uintptr_t;
#define INT64_MAX 0x7fffffffffffffffLL
#define INT64_MIN (-INT64_MAX - 1)

#include "hrmacro.h"

extern unsigned char *hrm_alloc(size_t len);
extern void hrm_free(unsigned char *p);
extern hrm_cell hrm_float(uint64_t bits, uint64_t meta);
extern double hrm_exp(double x);
extern double hrm_log(double x);
extern void hrm_fail(const unsigned char *msg, size_t len) __attribute__((noreturn));

/* V_ERR is a deferred Harbour error: Harbour folds the expression before
 * it resolves names or raises operand errors, so `.F. .AND. hidden` is .F.
 * and only an error that survives folding reaches the program. The first
 * error in evaluation order wins. */
enum { V_NIL, V_INT, V_DBL, V_LOG, V_STR, V_ERR };

/* M0 memvar storage: una tabla fija de asignaciones nombre -> celda Dyn.
 * El compilador PRIVATE/PUBLIC llama hrmacro_set; el evaluador de
 * identificadores consulta hrmacro_get antes de dar BASE/1003. La celda
 * es el 16-byte Dyn: tag 0/9 int, 1 NIL, 3 logical, 5 heap float,
 * 4 owned string. */
#define HRMV_TABLE 256
#define HRMV_NAME_MAX 63
typedef struct {
  char name[HRMV_NAME_MAX + 1];
  unsigned long long tag;
  unsigned long long payload;
  unsigned used;
} hrmv_slot;
static hrmv_slot hrmv_table[HRMV_TABLE];

static unsigned hrmv_fold(unsigned char c){ return c >= 'A' && c <= 'Z' ? c + 32u : c; }
static unsigned hrmv_namelen_eq(const unsigned char *a, const unsigned char *b, unsigned long long n){
  for (unsigned long long i = 0; i < n; i++) if (hrmv_fold(a[i]) != hrmv_fold(b[i])) return 0;
  return 1;
}
void hrmacro_set(unsigned long long tag, unsigned long long payload,
                 const unsigned char *name, unsigned long long name_len){
  if (name_len == 0 || name_len > 63) return;
  unsigned h = 5381u;
  for (unsigned long long i = 0; i < name_len; i++) h = h * 33u + hrmv_fold((unsigned char)name[i]);
  unsigned idx = h % HRMV_TABLE;
  hrmv_slot *free_slot = 0;
  for (unsigned probe = 0; probe < HRMV_TABLE; probe++) {
    hrmv_slot *k = &hrmv_table[(idx + probe) % HRMV_TABLE];
    if (!k->used) { if (!free_slot) free_slot = k; break; }
    if (k->name[0] == name[0] && hrmv_namelen_eq((const unsigned char*)k->name, name, name_len)) {
      k->tag = tag; k->payload = payload;
      return;
    }
  }
  if (!free_slot) return; /* tabla llena: límite con nombre */
  for (unsigned long long i = 0; i < name_len; i++) free_slot->name[i] = (char)hrmv_fold(name[i]);
  free_slot->name[name_len] = 0;
  free_slot->tag = tag;
  free_slot->payload = payload;
  free_slot->used = 1;
}

unsigned hrmacro_get(const unsigned char *name, unsigned long long name_len,
                     unsigned long long *tag, unsigned long long *payload){
  if (name_len == 0 || name_len > 63) return 0;
  unsigned h = 5381u;
  for (unsigned long long i = 0; i < name_len; i++) h = h * 33u + hrmv_fold((unsigned char)name[i]);
  unsigned idx = h % HRMV_TABLE;
  for (unsigned probe = 0; probe < HRMV_TABLE; probe++) {
    hrmv_slot *k = &hrmv_table[(idx + probe) % HRMV_TABLE];
    if (!k->used) return 0;
    if (k->name[0] == name[0] && hrmv_namelen_eq((const unsigned char*)k->name, name, name_len)) {
      *tag = k->tag; *payload = k->payload;
      return 1;
    }
  }
  return 0;
}
typedef struct {
  int kind;
  int64_t i;            /* V_INT value, V_LOG 0/1 */
  double d;             /* V_DBL value */
  int dec;              /* V_DBL decimals */
  const unsigned char *s; /* V_STR bytes */
  size_t n;             /* V_STR length */
  int owned;            /* V_STR: s came from hrm_alloc */
  unsigned char ebuf[96]; /* V_ERR message */
  size_t en;
} val;

enum { T_END, T_NUM, T_STR, T_IDENT, T_OP, T_LPAREN, T_RPAREN, T_COMMA, T_TRUE, T_FALSE, T_NIL, T_AND, T_OR, T_NOT, T_AMP };

typedef struct {
  const unsigned char *p, *end;
  int tok;
  const unsigned char *ts; size_t tn; /* token text (strings: contents) */
  int op;                              /* T_OP operator code */
  val num;                             /* T_NUM value */
} lex;

/* Operator codes. */
enum { O_PLUS = 1, O_MINUS, O_STAR, O_SLASH, O_PCT, O_POW, O_EQ, O_EXEQ, O_NE, O_LT, O_LE, O_GT, O_GE, O_DOLLAR, O_BANG };

__attribute__((noreturn)) static void fail_lit(const char *m) {
  size_t n = 0;
  while (m[n]) n++;
  hrm_fail((const unsigned char *)m, n);
}
__attribute__((noreturn)) static void syntax(void) { fail_lit("Error BASE/1449  Syntax error: &\n"); }

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
    if (q == h) syntax();
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
  if (c == '.') { if (dot_word(L)) return; syntax(); }
  if (c == '"' || c == '\'' || c == '[') {
    int close = c == '[' ? ']' : c;
    const unsigned char *q = L->p + 1;
    while (q < L->end && *q != close) q++;
    if (q >= L->end) syntax();
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
      if (c2 == '=') fail_lit("Error: macro assignments are not in this increment (M1)\n");
      syntax();
    case '{': fail_lit("Error: macro arrays, hashes and codeblocks are not in this increment (M1)\n");
    case '+': L->op = O_PLUS; return;
    case '-': L->op = O_MINUS; return;
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
    default: syntax();
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
static int dec_of(const val *v) { return v->kind == V_DBL ? v->dec : 0; }
static val mkdbl(double d, int dec) { val r = {0}; r.kind = V_DBL; r.d = d; r.dec = dec; return r; }
static val mkint(int64_t i) { val r = {0}; r.kind = V_INT; r.i = i; return r; }
static val mklog(int b) { val r = {0}; r.kind = V_LOG; r.i = b ? 1 : 0; return r; }

static double trunc_d(double x) {
  if (x >= 9.2e18 || x <= -9.2e18 || x != x) return x;
  return (double)(int64_t)x;
}

static val concat(val *a, val *b, int minus) {
  size_t n = a->n + b->n, k = 0, keep = a->n, trail = 0;
  unsigned char *o = hrm_alloc(n);
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

static val arith(int op, val *a, val *b) {
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
      return mkdbl(as_d(a) + as_d(b), dec_of(a) > dec_of(b) ? dec_of(a) : dec_of(b));
    case O_MINUS:
      if (ints && !__builtin_sub_overflow(a->i, b->i, &r)) return mkint(r);
      return mkdbl(as_d(a) - as_d(b), dec_of(a) > dec_of(b) ? dec_of(a) : dec_of(b));
    case O_STAR:
      if (ints && !__builtin_mul_overflow(a->i, b->i, &r)) return mkint(r);
      return mkdbl(as_d(a) * as_d(b), dec_of(a) + dec_of(b));
    case O_SLASH: {
      if (as_d(b) == 0.0) return mkint(0);
      if (ints && !(a->i == INT64_MIN && b->i == -1) && a->i % b->i == 0) return mkint(a->i / b->i);
      return mkdbl(as_d(a) / as_d(b), 2);
    }
    case O_PCT: {
      if (as_d(b) == 0.0) return mkint(0);
      if (ints) return mkint(b->i == -1 ? 0 : a->i % b->i);
      double x = as_d(a), y = as_d(b);
      return mkdbl(x - trunc_d(x / y) * y, 2);
    }
    default: { /* O_POW */
      double x = as_d(a), y = as_d(b), p;
      if (y == trunc_d(y) && y >= -1024.0 && y <= 1024.0) {
        int64_t k = (int64_t)y; int neg = k < 0; if (neg) k = -k;
        double base = x; p = 1.0;
        while (k) { if (k & 1) p *= base; base *= base; k >>= 1; }
        if (neg) p = 1.0 / p;
      } else p = hrm_exp(y * hrm_log(x));
      return mkdbl(p, 2);
    }
  }
}

static val expr_or(lex *L);
static val eval_text(const unsigned char *src, size_t len);

static val primary(lex *L) {
  val v = {0};
  switch (L->tok) {
    case T_NUM: v = L->num; next(L); return v;
    case T_STR: v.kind = V_STR; v.s = L->ts; v.n = L->tn; next(L); return v;
    case T_TRUE: next(L); return mklog(1);
    case T_FALSE: next(L); return mklog(0);
    case T_NIL: next(L); v.kind = V_NIL; return v;
    case T_LPAREN:
      /* (a, b, c) is a list expression: the last value (Harbour). */
      next(L);
      v = expr_or(L);
      while (L->tok == T_COMMA) {
        drop(&v);
        next(L);
        v = expr_or(L);
      }
      if (L->tok != T_RPAREN) syntax();
      next(L);
      return v;
    case T_AMP: {
      /* Nested macro: &(text) evaluates text; &name names a variable. */
      next(L);
      if (L->tok == T_IDENT) {
        val e = mkerr2("Error BASE/1003  Variable does not exist: ", L->ts, L->tn);
        next(L);
        return e;
      }
      if (L->tok != T_LPAREN) syntax();
      next(L);
      v = expr_or(L);
      if (L->tok != T_RPAREN) syntax();
      next(L);
      if (v.kind == V_ERR) return v;
      if (v.kind != V_STR) { drop(&v); syntax(); }
      val r = eval_text(v.s, v.n);
      drop(&v);
      return r;
    }
    case T_IDENT: {
      const unsigned char *s = L->ts; size_t n = L->tn;
      next(L);
      if (L->tok == T_LPAREN) {
        /* Calls are M2: parse and release the arguments, defer the limit. */
        next(L);
        if (L->tok != T_RPAREN) {
          for (;;) {
            val a = expr_or(L);
            drop(&a);
            if (L->tok != T_COMMA) break;
            next(L);
          }
        }
        if (L->tok != T_RPAREN) syntax();
        next(L);
        return mkerr2("Error: macro function calls are not in this increment (M1): ", s, n);
      }
      /* M0 memvar lookup: PRIVATE/PUBLIC values stored by hrc codegen. */
      unsigned long long mt, mp;
      if (hrmacro_get(s, n, &mt, &mp)) {
        val v;
        switch (mt) {
          case 0: case 9: v.kind = V_INT; v.i = (long long)mp; break;
          case 1: v.kind = V_NIL; break;
          case 3: v.kind = V_LOG; v.i = mp ? 1 : 0; break;
          default: return mkerr2("Error BASE/1003  Variable does not exist: ", s, n);
        }
        return v;
      }
      return mkerr2("Error BASE/1003  Variable does not exist: ", s, n);
    }
    default: syntax();
  }
  return v;
}

/* Unary operators bind tighter than ^ (Harbour: -2 ^ 2 is 4). */
static val unary(lex *L) {
  if (L->tok == T_OP && L->op == O_MINUS) {
    next(L);
    val v = unary(L);
    if (v.kind == V_INT) {
      if (v.i == INT64_MIN) return mkdbl(-(double)v.i, 0);
      v.i = -v.i; return v;
    }
    if (v.kind == V_DBL) { v.d = -v.d; return v; }
    if (v.kind == V_ERR) return v;
    drop(&v);
    return mkerr("Error BASE/1080  Argument error: -");
  }
  if (L->tok == T_OP && L->op == O_PLUS) { next(L); return unary(L); }
  return primary(L);
}

static val power(lex *L) {
  val a = unary(L);
  while (L->tok == T_OP && L->op == O_POW) {
    next(L);
    val b = unary(L);
    a = arith(O_POW, &a, &b);
  }
  return a;
}

static val term(lex *L) {
  val a = power(L);
  while (L->tok == T_OP && (L->op == O_STAR || L->op == O_SLASH || L->op == O_PCT)) {
    int op = L->op; next(L);
    val b = power(L);
    a = arith(op, &a, &b);
  }
  return a;
}

static val sum(lex *L) {
  val a = term(L);
  while (L->tok == T_OP && (L->op == O_PLUS || L->op == O_MINUS)) {
    int op = L->op; next(L);
    val b = term(L);
    a = arith(op, &a, &b);
  }
  return a;
}

static val relation(lex *L) {
  val a = sum(L);
  while (L->tok == T_OP && L->op >= O_EQ && L->op <= O_DOLLAR) {
    int op = L->op; next(L);
    val b = sum(L);
    if (op == O_DOLLAR) {
      val e;
      if (pending(&a, &b, &e)) { a = e; continue; }
      if (a.kind != V_STR || b.kind != V_STR) { drop(&a); drop(&b); a = arg_err(O_DOLLAR); continue; }
      int found = 0;
      if (a.n > 0 && a.n <= b.n) {
        for (size_t j = 0; j + a.n <= b.n && !found; j++) {
          size_t m = 0;
          while (m < a.n && b.s[j + m] == a.s[m]) m++;
          if (m == a.n) found = 1;
        }
      }
      drop(&a); drop(&b);
      a = mklog(found);
    } else a = compare(op, &a, &b);
  }
  return a;
}

static val negation(lex *L) {
  if (L->tok == T_NOT || (L->tok == T_OP && L->op == O_BANG)) {
    next(L);
    val v = negation(L);
    if (v.kind == V_ERR) return v;
    if (v.kind != V_LOG) { drop(&v); return mkerr("Error BASE/1077  Argument error: .NOT."); }
    v.i = !v.i;
    return v;
  }
  return relation(L);
}

/* Constant folding of .AND./.OR. (expropt2.c): a logical constant on
 * either side decides or passes the other operand through unchanged. */
static val logic(int is_and, val *a, val *b) {
  if (a->kind == V_LOG) {
    if (is_and ? !a->i : a->i) { drop(b); return *a; }
    return *b;
  }
  if (b->kind == V_LOG) {
    if (is_and ? b->i : !b->i) return *a;
    drop(a); return *b;
  }
  if (a->kind == V_ERR) { drop(b); return *a; }
  drop(a); drop(b);
  return mkerr(is_and ? "Error BASE/1078  Argument error: .AND." : "Error BASE/1079  Argument error: .OR.");
}

static val conj(lex *L) {
  val a = negation(L);
  while (L->tok == T_AND) { next(L); val b = negation(L); a = logic(1, &a, &b); }
  return a;
}

static val expr_or(lex *L) {
  val a = conj(L);
  while (L->tok == T_OR) { next(L); val b = conj(L); a = logic(0, &a, &b); }
  return a;
}

static uint64_t dbl_bits(double d) { union { double d; uint64_t u; } x; x.d = d; return x.u; }

/* Entry: rdi/rsi = borrowed macro text -> rax/rdx = owned Dyn cell. */
static val eval_text(const unsigned char *src, size_t len) {
  lex L;
  L.p = src; L.end = src + len; L.op = 0; L.ts = 0; L.tn = 0; L.num = mkint(0);
  next(&L);
  if (L.tok == T_END) syntax();
  val v = expr_or(&L);
  if (L.tok != T_END) { drop(&v); syntax(); }
  return v;
}

hrm_cell hrmacro_eval(const unsigned char *src, size_t len) {
  val v = eval_text(src, len);
  if (v.kind == V_ERR) hrm_fail(v.ebuf, v.en);
  hrm_cell c;
  switch (v.kind) {
    /* Folded integers carry literal widths in Harbour (10000000000 prints
     * in 12 columns, not 20): hbc's literal-integer kind 9. */
    case V_INT: c.tag = 9; c.payload = (uint64_t)v.i; return c;
    case V_LOG: c.tag = 3; c.payload = (uint64_t)v.i; return c;
    case V_NIL: c.tag = 1; c.payload = 0; return c;
    case V_STR: {
      unsigned char *o = (unsigned char *)v.s;
      if (!v.owned) {
        o = hrm_alloc(v.n);
        for (size_t j = 0; j < v.n; j++) o[j] = v.s[j];
      }
      c.tag = 4; c.payload = (uint64_t)(uintptr_t)o; return c;
    }
    default: {
      uint64_t width = (v.d >= 10000000000.0 || v.d <= -1000000000.0) ? 20 : 10;
      return hrm_float(dbl_bits(v.d), (width << 16) | (uint64_t)v.dec);
    }
  }
}
