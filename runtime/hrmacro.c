/* Own MIT macro evaluator (M0+M1): PRIVATE/PUBLIC memvar storage and a
 * bounded expression evaluator for the `&` operator. No libc, no Harbour
 * VM: the program stays native, the evaluator is a small embedded
 * interpreter for the cases that genuinely need it (issue roadmap).
 *
 * The memvar table is a fixed-size open-addressing hash (256 slots) with
 * linear probing, storing {name, tag, payload, owned_str, owned_len}.
 * Owned strings are allocated through the OS allocate()/deallocate()
 * primitives supplied by the unity build (same primitives as the DBF
 * blob) so they survive across helper calls and are freed deterministically
 * when overwritten or at app close. */
#include "hrmacro.h"
#include "hrdyn.h"

/* OS primitives: supplied by the unity build (same as the DBF blob).
 * The unity build renames these to hrdbf_os_* via the allocate/open_ro
 * macros before including this file. */
#ifndef HRC_ALLOC_DEFINED
extern void *hrmacro_allocate(unsigned long long n);
extern void hrmacro_deallocate(void *p, unsigned long long n);
#endif

/* ------------------------------------------------------------------ */
/* Memvar table                                                        */
/* ------------------------------------------------------------------ */

#define HRC_TABLE_SIZE 256
#define HRC_NAME_MAX 254
#define HRC_STR_MAX (64u*1024u*1024u)

typedef struct {
  char name[HRC_NAME_MAX + 1];
  uint64_t tag;
  int64_t payload;
  char *owned_str;
  size_t owned_len;
  unsigned used;
} hrc_slot;

static hrc_slot hrc_table[HRC_TABLE_SIZE];
static unsigned hrc_initialized;

static unsigned hrc_hash(const char *name, size_t len){
  unsigned h = 5381;
  for (size_t i = 0; i < len; i++) h = (h * 33 + (unsigned char)name[i]) & 0xFFFFFFFF;
  return h;
}

static void hrc_slot_clear(hrc_slot *s){
  if (s->owned_str) { hrmacro_deallocate(s->owned_str, s->owned_len + 1); s->owned_str = 0; s->owned_len = 0; }
  s->name[0] = 0; s->tag = 0; s->payload = 0; s->used = 0;
}

void hrc_macro_init(void){
  if (hrc_initialized) return;
  for (int i = 0; i < HRC_TABLE_SIZE; i++) { hrc_table[i].used = 0; hrc_table[i].owned_str = 0; hrc_table[i].name[0] = 0; }
  hrc_initialized = 1;
}

void hrc_macro_free(void){
  if (!hrc_initialized) return;
  for (int i = 0; i < HRC_TABLE_SIZE; i++) hrc_slot_clear(&hrc_table[i]);
  hrc_initialized = 0;
}

void hrc_macro_set(const char *name, size_t name_len, uint64_t tag, int64_t payload, const char *str, size_t str_len){
  hrc_macro_init();
  if (name_len == 0 || name_len > HRC_NAME_MAX) return;
  unsigned h = hrc_hash(name, name_len) % HRC_TABLE_SIZE;
  for (int probe = 0; probe < HRC_TABLE_SIZE; probe++) {
    hrc_slot *s = &hrc_table[(h + probe) % HRC_TABLE_SIZE];
    if (!s->used || (s->name[0] && 0 == __builtin_memcmp(s->name, name, name_len) && s->name[name_len] == 0)) {
      hrc_slot_clear(s);
      for (size_t i = 0; i < name_len; i++) s->name[i] = name[i];
      s->name[name_len] = 0;
      s->tag = tag; s->payload = payload; s->used = 1;
      if (str && str_len > 0 && str_len <= HRC_STR_MAX) {
        s->owned_str = (char *)hrmacro_allocate(str_len + 1);
        if (s->owned_str) {
          for (size_t i = 0; i < str_len; i++) s->owned_str[i] = str[i];
          s->owned_str[str_len] = 0;
          s->owned_len = str_len;
        }
      }
      return;
    }
  }
}

int hrc_macro_get(const char *name, size_t name_len, hrc_value *out){
  hrc_macro_init();
  if (name_len == 0 || name_len > HRC_NAME_MAX) return 0;
  unsigned h = hrc_hash(name, name_len) % HRC_TABLE_SIZE;
  for (int probe = 0; probe < HRC_TABLE_SIZE; probe++) {
    hrc_slot *s = &hrc_table[(h + probe) % HRC_TABLE_SIZE];
    if (!s->used) return 0;
    if (s->name[0] && 0 == __builtin_memcmp(s->name, name, name_len) && s->name[name_len] == 0) {
      if (!out) return 1;
      out->tag = s->tag; out->payload = s->payload;
      out->owned_str = s->owned_str; out->owned_len = s->owned_len;
      return 1;
    }
  }
  return 0;
}

int hrc_macro_exists(const char *name, size_t name_len){
  return hrc_macro_get(name, name_len, 0);
}

void hrc_value_free(hrc_value *v){
  if (v && v->owned_str) { hrmacro_deallocate(v->owned_str, v->owned_len + 1); v->owned_str = 0; v->owned_len = 0; }
  v->tag = 0; v->payload = 0;
}

/* ------------------------------------------------------------------ */
/* Expression tokenizer + recursive descent evaluator (M1)             */
/* ------------------------------------------------------------------ */

typedef enum { TOK_END, TOK_NUM, TOK_STR, TOK_IDENT, TOK_PLUS, TOK_MINUS,
               TOK_STAR, TOK_SLASH, TOK_PCT, TOK_LPAREN, TOK_RPAREN,
               TOK_ERROR } tok_kind;

typedef struct {
  tok_kind kind;
  int64_t num;          /* TOK_NUM */
  const char *str;      /* TOK_STR: pointer into source, not NUL-terminated */
  size_t str_len;
  const char *ident;    /* TOK_IDENT: pointer into source */
  size_t ident_len;
} token;

typedef struct {
  const char *src; size_t len; size_t pos;
  token tok;             /* current token */
  hrc_error err;
} hrc_parser;

static void hrc_skip_ws(hrc_parser *p){
  while (p->pos < p->len && (p->src[p->pos] == ' ' || p->src[p->pos] == '\t')) p->pos++;
}

static void hrc_next_token(hrc_parser *p){
  hrc_skip_ws(p);
  if (p->pos >= p->len) { p->tok.kind = TOK_END; return; }
  char c = p->src[p->pos];
  if (c >= '0' && c <= '9') {
    int64_t v = 0;
    size_t start = p->pos;
    while (p->pos < p->len && p->src[p->pos] >= '0' && p->src[p->pos] <= '9') { v = v * 10 + (p->src[p->pos] - '0'); p->pos++; }
    p->tok.kind = TOK_NUM; p->tok.num = v;
    (void)start;
    return;
  }
  if (c == '"') {
    p->pos++; size_t start = p->pos;
    while (p->pos < p->len && p->src[p->pos] != '"') p->pos++;
    if (p->pos >= p->len) { p->err = HRC_SYNTAX; p->tok.kind = TOK_ERROR; return; }
    p->tok.kind = TOK_STR; p->tok.str = p->src + start; p->tok.str_len = p->pos - start;
    p->pos++; /* skip closing quote */
    return;
  }
  if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_') {
    size_t start = p->pos;
    while (p->pos < p->len && ((p->src[p->pos] >= 'a' && p->src[p->pos] <= 'z') || (p->src[p->pos] >= 'A' && p->src[p->pos] <= 'Z') || (p->src[p->pos] >= '0' && p->src[p->pos] <= '9') || p->src[p->pos] == '_')) p->pos++;
    p->tok.kind = TOK_IDENT; p->tok.ident = p->src + start; p->tok.ident_len = p->pos - start;
    return;
  }
  p->pos++;
  switch (c) {
    case '+': p->tok.kind = TOK_PLUS; return;
    case '-': p->tok.kind = TOK_MINUS; return;
    case '*': p->tok.kind = TOK_STAR; return;
    case '/': p->tok.kind = TOK_SLASH; return;
    case '%': p->tok.kind = TOK_PCT; return;
    case '(': p->tok.kind = TOK_LPAREN; return;
    case ')': p->tok.kind = TOK_RPAREN; return;
    default: p->err = HRC_SYNTAX; p->tok.kind = TOK_ERROR; return;
  }
}

static hrc_error hrc_parse_expr(hrc_parser *p, hrc_value *out);

static hrc_error hrc_eval_binary(tok_kind op, hrc_value *lhs, hrc_value *rhs, hrc_value *out){
  /* M1: numeric and string arithmetic. String + string concatenates.
   * All results are integers or owned strings. */
  if (op == TOK_PLUS && lhs->tag == 4 && rhs->tag == 4) {
    /* string concat */
    size_t total = lhs->owned_len + rhs->owned_len;
    if (total > HRC_STR_MAX) return HRC_LIMIT;
    char *buf = (char *)hrmacro_allocate(total + 1);
    if (!buf) return HRC_MEMORY;
    for (size_t i = 0; i < lhs->owned_len; i++) buf[i] = lhs->owned_str[i];
    for (size_t i = 0; i < rhs->owned_len; i++) buf[lhs->owned_len + i] = rhs->owned_str[i];
    buf[total] = 0;
    /* free the left operand's owned string (the evaluator owns it) */
    if (lhs->owned_str) hrmacro_deallocate(lhs->owned_str, lhs->owned_len + 1);
    out->tag = 4; out->payload = 0; out->owned_str = buf; out->owned_len = total;
    return HRC_OK;
  }
  /* numeric: promote strings to nothing (type error in M1) */
  if (lhs->tag == 4 || rhs->tag == 4) return HRC_TYPE;
  if (lhs->tag != 0 && lhs->tag != 9) return HRC_TYPE;
  if (rhs->tag != 0 && rhs->tag != 9) return HRC_TYPE;
  int64_t a = lhs->payload, b = rhs->payload;
  switch (op) {
    case TOK_PLUS: out->payload = a + b; break;
    case TOK_MINUS: out->payload = a - b; break;
    case TOK_STAR: out->payload = a * b; break;
    case TOK_SLASH: if (b == 0) return HRC_TYPE; out->payload = a / b; break;
    case TOK_PCT: if (b == 0) return HRC_TYPE; out->payload = a % b; break;
    default: return HRC_SYNTAX;
  }
  out->tag = 0; out->payload = out->payload;
  out->owned_str = 0; out->owned_len = 0;
  /* free owned strings from operands that were promoted */
  return HRC_OK;
}

static hrc_error hrc_parse_term(hrc_parser *p, hrc_value *out);

static hrc_error hrc_parse_atom(hrc_parser *p, hrc_value *out){
  if (p->err) return p->err;
  switch (p->tok.kind) {
    case TOK_NUM:
      out->tag = 0; out->payload = p->tok.num;
      out->owned_str = 0; out->owned_len = 0;
      hrc_next_token(p);
      return HRC_OK;
    case TOK_STR: {
      size_t len = p->tok.str_len;
      const char *src = p->tok.str;
      hrc_next_token(p);
      if (len == 0) { out->tag = 4; out->payload = 0; out->owned_str = 0; out->owned_len = 0; return HRC_OK; }
      char *buf = (char *)hrmacro_allocate(len + 1);
      if (!buf) return HRC_MEMORY;
      for (size_t i = 0; i < len; i++) buf[i] = src[i];
      buf[len] = 0;
      out->tag = 4; out->payload = 0; out->owned_str = buf; out->owned_len = len;
      return HRC_OK;
    }
    case TOK_IDENT: {
      /* memvar lookup (M0) */
      const char *name = p->tok.ident;
      size_t name_len = p->tok.ident_len;
      hrc_next_token(p);
      hrc_value v;
      if (!hrc_macro_get(name, name_len, &v)) return HRC_UNDEF;
      *out = v;
      return HRC_OK;
    }
    case TOK_LPAREN: {
      hrc_next_token(p);
      hrc_error e = hrc_parse_expr(p, out);
      if (e) return e;
      if (p->tok.kind != TOK_RPAREN) { p->err = HRC_SYNTAX; return HRC_SYNTAX; }
      hrc_next_token(p);
      return HRC_OK;
    }
    case TOK_MINUS: {
      /* unary minus */
      hrc_next_token(p);
      hrc_value v;
      hrc_error e = hrc_parse_atom(p, &v);
      if (e) return e;
      if (v.tag != 0 && v.tag != 9) return HRC_TYPE;
      out->tag = 0; out->payload = -v.payload;
      out->owned_str = 0; out->owned_len = 0;
      return HRC_OK;
    }
    default:
      p->err = HRC_SYNTAX; return HRC_SYNTAX;
  }
}

static hrc_error hrc_parse_term(hrc_parser *p, hrc_value *out){
  hrc_error e = hrc_parse_atom(p, out);
  if (e) return e;
  while (p->tok.kind == TOK_STAR || p->tok.kind == TOK_SLASH || p->tok.kind == TOK_PCT) {
    tok_kind op = p->tok.kind;
    hrc_next_token(p);
    hrc_value rhs;
    e = hrc_parse_atom(p, &rhs);
    if (e) return e;
    hrc_value result;
    e = hrc_eval_binary(op, out, &rhs, &result);
    if (e) return e;
    *out = result;
  }
  return HRC_OK;
}

static hrc_error hrc_parse_expr(hrc_parser *p, hrc_value *out){
  hrc_error e = hrc_parse_term(p, out);
  if (e) return e;
  while (p->tok.kind == TOK_PLUS || p->tok.kind == TOK_MINUS) {
    tok_kind op = p->tok.kind;
    hrc_next_token(p);
    hrc_value rhs;
    e = hrc_parse_term(p, &rhs);
    if (e) return e;
    hrc_value result;
    e = hrc_eval_binary(op, out, &rhs, &result);
    if (e) return e;
    *out = result;
  }
  return HRC_OK;
}

hrc_error hrc_macro_eval(const char *src, size_t len, hrc_value *out){
  hrc_macro_init();
  if (!src || len == 0 || len > HRC_STR_MAX) return HRC_LIMIT;
  hrc_parser p;
  p.src = src; p.len = len; p.pos = 0; p.err = HRC_OK;
  hrc_next_token(&p);
  hrc_error e = hrc_parse_expr(&p, out);
  if (e) return e;
  if (p.tok.kind != TOK_END) return HRC_SYNTAX;
  return HRC_OK;
}
