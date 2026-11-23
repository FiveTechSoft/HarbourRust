import re, math, sys
from decimal import Decimal, getcontext, ROUND_HALF_UP, ROUND_HALF_EVEN
getcontext().prec = 100

# ---------- parsing helpers ----------
def split_args(s):
    args, depth, cur, instr = [], 0, '', False
    for ch in s:
        if ch == "'": instr = not instr; cur += ch
        elif instr: cur += ch
        elif ch == '(': depth += 1; cur += ch
        elif ch == ')': depth -= 1; cur += ch
        elif ch == ',' and depth == 0: args.append(cur.strip()); cur = ''
        else: cur += ch
    if cur.strip(): args.append(cur.strip())
    return args

def parse_literal_correct(s):
    return float(s)

def parse_literal_accum(s):
    # accumulate int part digit by digit, frac digits then divide by 10^k
    m = re.fullmatch(r'(-?)(\d+)(?:\.(\d+))?', s)
    if not m: return float(s)
    sign, ip, fp = m.group(1), m.group(2), m.group(3) or ''
    v = 0.0
    for ch in ip: v = v*10.0 + (ord(ch)-48)
    if fp:
        f = 0.0
        for ch in fp: f = f*10.0 + (ord(ch)-48)
        v = v + f / 10.0**len(fp)
    return -v if sign=='-' else v

PARSE = parse_literal_correct

class N:
    __slots__=('v','dec','len')
    def __init__(s, v, dec=0, ln=10): s.v=float(v); s.dec=dec; s.len=ln
    def __repr__(s): return 'N(%r,d%d,l%d)'%(s.v,s.dec,s.len)

def lit(s):
    m = re.fullmatch(r'(-?)(\d+)(?:\.(\d+))?', s)
    dec = len(m.group(3) or '') if m else 0
    return N(PARSE(s), dec, 10)

def round_alg(x, d, variant):
    # returns (value, decmeta, lenmeta)
    if d != d or x != x: return N(float('nan'), 0, 10)
    ad = abs(d)
    loop = variant.get('loopscale', False)
    if ad <= 308:
        p = 10.0**ad
    else:
        p = float('inf')
    if loop and ad <= 308:
        y = x
        for _ in range(ad):
            y = y*10.0 if d>=0 else y/10.0
    else:
        if d >= 0: y = x * p
        else: y = x / p
    if not variant.get('nolift'):
        y = y * (1.0 + 2**-52)
    a = abs(y) + 0.5
    if a >= 2.0**62: r = a
    else: r = float(math.floor(a))
    r = math.copysign(r, y)
    if loop and ad <= 308:
        res = r
        for _ in range(ad):
            res = res/10.0 if d>=0 else res*10.0
    else:
        if d >= 0:
            res = r / p if variant.get('unscale','div')=='div' else r * (1.0/p)
        else:
            res = r * p
    dec = max(d, 0)
    if dec > 65535: dec = 65535
    ln = 20 if (res > 9999999999.0 or res < -999999999.0) else 10
    return N(res, dec, ln)

CURV = {}
def image16(t, variant=None):
    variant = CURV if variant is None else variant
    if t == 0.0: return '0'*16, 0
    d = Decimal(t)
    e10 = d.adjusted()
    q = Decimal(1).scaleb(e10-15)
    Nn = int((d/q).quantize(Decimal(1), rounding=ROUND_HALF_EVEN if variant.get('halfeven') else ROUND_HALF_UP))
    if Nn >= 10**16: Nn //= 10; e10 += 1
    return '%016d' % Nn, e10

def str_core(v, w, d, explicit_dec):
    if d < 0: d = 0
    if w is not None and w <= 0: w = 10
    if v != v or v in (float('inf'), float('-inf')):
        fld = w if w is not None else 10
        return '*'*fld
    neg = math.copysign(1.0, v) < 0
    av = abs(v)
    if explicit_dec:
        th = CURV.get('halfth', 99)
        # 'halfskipint' models the ported E_0320 rule (skip the half-add
        # when |v| is integral); the ported assembler has it ON, so the
        # baseline and every ported-rule variant below carry it.
        if d <= th and not (CURV.get('halfskipint') and av == math.floor(av) and av < 2**53):
            t = float(av + 0.5 * 10.0**(-d))   # double add
            if CURV.get('str3lift'):
                t = t * (1.0 + 2**-52)          # variant: ulp lift inside Str
        else:
            t = av
        digits, e10 = image16(t)
        mode = 'trunc'
    else:
        digits, e10 = image16(av)
        mode = 'round'
    intd = e10 + 1
    # produce digit string and round/truncate at d decimals
    keep = intd + d
    if keep <= 0:
        # value below resolution
        if mode=='round' and intd+d==0 and digits[0] >= '5':
            kept, intd = '1', -d+1
        else:
            kept, intd = '0', 1 if d==0 else -d+1
            kept='0'; 
    elif keep >= 16:
        kept = digits + '0'*(keep-16)
    else:
        kept = digits[:keep]
        if mode=='round' and digits[keep] >= '5':
            kept = str(int(kept)+1)
            if len(kept) > keep: intd += 1; kept = kept[:-1]  # 99..9+1 = 100..0: shift right
    # recompute int/frac split with possibly-updated intd
    if intd <= 0:
        intpart = '0'
        frac = '0'*(-intd) + kept
    else:
        if len(kept) <= intd: intpart = kept + '0'*(intd-len(kept)); frac=''
        else: intpart = kept[:intd]; frac = kept[intd:]
    frac = (frac + '0'*d)[:d]
    body = intpart + ('.'+frac if d>0 else '')
    if neg and body.replace('.','').strip('0') != '': body = '-'+body
    if w is not None:
        if len(body) > w:
            # defaulted-len expansion is handled by caller (omitted width)
            return None if w < 0 else '*'*w
        return body.rjust(w)
    return body

def str_default(v, decmeta, lenmeta):
    # Str(x): len/dec from metadata; expand on overflow
    w = lenmeta; d = decmeta
    fld = w + (1+d if d>0 else 0)
    s = str_core(v, fld, d, False)
    if s is not None and len(s) <= fld and not s.startswith('*'): return s
    # expansion: fit
    body = str_core(v, None, d, False)
    intd = len(body.split('.')[0].lstrip('-'))
    if d > 0:
        len2 = intd + d + 3
        fld2 = len2 + 1 + d
    else:
        len2 = intd + 1
        fld2 = len2
    return str_core(v, fld2, d, False)

def str2(v, w):  # Str(x,w): dec = 0, no +half (M_1464)
    return str_core(v, w, 0, False)

def hb_ntos(n): return str_default(n.v, n.dec, n.len).lstrip(' ')

# ---------- expression evaluator ----------
def evale(expr, setdec, variant):
    expr = expr.strip()
    m = re.fullmatch(r'Round\((.*)\)', expr)
    if m:
        args = split_args(m.group(1))
        x = evale(args[0], setdec, variant)
        d = evale(args[1], setdec, variant) if len(args)>1 else None
        if not isinstance(x, N) or d is None or not isinstance(d, N):
            return ('ERR',)
        di = int(d.v)  # trunc toward zero
        r = round_alg(x.v, di, variant)
        # Harbour: result metadata dec=max(d,0); but if d was float like 1.9 -> trunc 1
        return r
    m = re.fullmatch(r'Str\((.*)\)', expr)
    if m:
        args = split_args(m.group(1))
        x = evale(args[0], setdec, variant)
        if len(args) == 1: return ('S', str_default(x.v, x.dec, x.len))
        w = int(evale(args[1], setdec, variant).v)
        if len(args) == 2:
            if variant.get('str2round'):
                r = round_alg(x.v, 0, variant)
                return ('S', str_core(r.v, w, 0, False))
            return ('S', str2(x.v, w))
        d = int(evale(args[2], setdec, variant).v)
        # DEFAULT (ported rule): the double half-add + truncate inside
        # str_core (E_0320 skip-when-integral, M_1235 truncate at d).
        # 'str3round': the historical approximation (round_alg first,
        # then plain str_core) - NOT the ported rule, kept for contrast.
        if variant.get('str3round'):
            dd = d if d >= 0 else 0
            r = round_alg(x.v, dd, variant)
            return ('S', str_core(r.v, w, dd, False))
        return ('S', str_core(x.v, w, d, True))
    m = re.fullmatch(r'Val\((.*)\)', expr)
    if m:
        s = evale(m.group(1), setdec, variant)
        if isinstance(s, tuple) and s[0]=='S':
            st = s[1].lstrip(' ')
            mm = re.match(r'-?\d+(?:\.\d+)?', st)
            if not mm: return N(0.0, 0, len(s[1]))
            txt = mm.group(0)
            dec = len(txt.split('.')[1]) if '.' in txt else 0
            return N(float(txt), dec, len(s[1]) - (dec+1 if dec>0 else 0))
        return N(0.0,0,10)
    m = re.fullmatch(r'Int\((.*)\)', expr)
    if m:
        x = evale(m.group(1), setdec, variant)
        return N(float(math.floor(x.v)) if x.v>=0 else float(math.ceil(abs(x.v)))* -1 if False else float(int(x.v)), 0, 10)
    m = re.fullmatch(r'Min\((.*)\)', expr)
    if m:
        a,b = split_args(m.group(1)); x=evale(a,setdec,variant); y=evale(b,setdec,variant)
        return x if x.v<=y.v else y
    m = re.fullmatch(r'Sqrt\((.*)\)', expr)
    if m:
        x = evale(m.group(1), setdec, variant); return N(math.sqrt(x.v), 0, 10)
    m = re.fullmatch(r'Exp\((.*)\)', expr)
    if m:
        x = evale(m.group(1), setdec, variant); return N(math.exp(x.v), 0, 10)
    m = re.fullmatch(r'Log\((.*)\)', expr)
    if m:
        x = evale(m.group(1), setdec, variant); return N(math.log(x.v), 0, 10)
    # binary ops, top-level, lowest precedence first
    depth=0; instr=False; ops=[]
    for i,ch in enumerate(expr):
        if ch=="'": instr=not instr
        elif instr: pass
        elif ch=='(': depth+=1
        elif ch==')': depth-=1
        elif depth==0 and ch in '+-' and i>0 and expr[i-1] not in 'eE+-*/(':
            ops.append((i,ch))
    if ops:
        i,ch = ops[0]
        x = evale(expr[:i], setdec, variant); y = evale(expr[i+1:], setdec, variant)
        v = x.v + y.v if ch=='+' else x.v - y.v
        return N(v, max(x.dec,y.dec), 10)
    depth=0; instr=False; ops=[]
    for i,ch in enumerate(expr):
        if ch=="'": instr=not instr
        elif instr: pass
        elif ch=='(': depth+=1
        elif ch==')': depth-=1
        elif depth==0 and ch in '*/':
            ops.append((i,ch))
    if ops:
        i,ch = ops[0]
        x = evale(expr[:i], setdec, variant); y = evale(expr[i+1:], setdec, variant)
        if ch=='*': return N(x.v*y.v, x.dec+y.dec, 10)
        else:
            if y.v == 0.0: return ('ERRD',)
            return N(x.v/y.v, setdec, 10)
    if expr.startswith('(') and expr.endswith(')'):
        return evale(expr[1:-1], setdec, variant)
    if re.fullmatch(r"'[^']*'", expr):
        return ('S', expr[1:-1])
    if re.fullmatch(r'-?[\d.]+', expr):
        return lit(expr)
    return ('UNK', expr)

def run(variant):
    CURV.clear(); CURV.update(variant)
    seen=set()
    results=[]
    global PARSE
    PARSE = parse_literal_accum if variant.get('parse')=='accum' else parse_literal_correct
    setdec = 2
    total = match = 0
    fails = []
    for line in open(RESULTS_TSV):
        p = line.rstrip('\n').split('\t')
        if len(p) < 3: continue
        cid, expr, res = p[0], p[1], p[2]
        sec = cid.split('_')[0]
        if sec == 'K' or sec == 'L': continue
        e = expr
        m = re.match(r'SET DECIMALS TO (\d+); SET FIXED (ON|OFF); (.*)$', e)
        if m: setdec_cur = int(m.group(1)); e = m.group(3)
        else: setdec_cur = 2
        try:
            r = evale(e, setdec_cur, variant)
        except Exception as ex:
            r = ('EXC', str(ex))
        # build output line(s)
        if isinstance(r, tuple) and r[0]=='S':
            outs = ['%s|C|%s' % (cid, r[1])]
        elif isinstance(r, N):
            col1 = hb_ntos(r); col2 = str_default(r.v, r.dec, r.len)
            col3 = str_core(r.v, 30, 12, True); col4 = str_core(r.v, 34, 17, True)
            outs = ['%s|N|[%s]|[%s]|[%s]|[%s]' % (cid, col1, col2, col3, col4)]
            if sec == 'O':
                outs.append('%s|raw|[%s]' % (cid, str_default(r.v, r.dec, r.len)))
        else:
            continue  # ERR/UNK: skip
        # expected lines from out.txt for this cid
        seen.add(cid)
        total += 1
        exp = expmap.get(cid, [])
        ok = outs == exp
        results.append((cid, expr, ok))
        if ok: match += 1
        else:
            fails.append((cid, expr, exp, outs))
    run.last_seen = seen
    run.results = results
    return total, match, fails

expmap = {}
import sys as _sys
RESULTS_TSV = _sys.argv[1] if len(_sys.argv) > 1 else '/tmp/spec/round-oracle-spec/results.tsv'
OUT_TXT = _sys.argv[2] if len(_sys.argv) > 2 else '/tmp/spec/round-oracle-spec/out.txt'
for line in open(OUT_TXT):
    line = line.rstrip('\n')
    cid = line.split('|')[0]
    expmap.setdefault(cid, []).append(line)

if __name__ == '__main__':
    # Driver: runs ALL variants against the full case set and writes the
    # per-case verdict log. Usage:
    #   python3 fullsim.py [results.tsv] [out.txt] [log-out]
    # (defaults: the /tmp/spec oracle paths; log to stdout).
    import hashlib
    log = _sys.argv[3] if len(_sys.argv) > 3 else None
    w = open(log, 'w') if log else _sys.stdout
    def emit(*a):
        print(*a, file=w)
    emit('# fullsim.py reproducibility record')
    emit('#')
    emit('# NOTE: fullsim.py is an APPROXIMATE simulator, not a proof:')
    emit('# - Python float exponentiation and the assembler repeated')
    emit('#   squaring in the compiled implementation can differ by ulps')
    emit('#   in extreme cases;')
    emit('# - the K/L invalid-shape rows and the macro rows are covered')
    emit('#   by the compiled harness (check.sh), not by this value')
    emit('#   simulation;')
    emit('# - the 96 O-section pairs count TWICE in every score below.')
    emit('# The simulator informed design choices during development; it')
    emit('# is NOT evidence of clean-room separation or licence status.')
    emit('# usage: python3 tests/round-bb/fullsim.py /path/to/results.tsv /path/to/out.txt /path/to/log')
    emit('fullsim.py  sha256', hashlib.sha256(open(__file__,'rb').read()).hexdigest())
    emit('results.tsv sha256', hashlib.sha256(open(RESULTS_TSV,'rb').read()).hexdigest())
    emit('out.txt     sha256', hashlib.sha256(open(OUT_TXT,'rb').read()).hexdigest())
    emit()
    # Baseline flags match the PORTED rule exactly: str_core explicit_dec
    # path with 'halfskipint' ON (E_0320: the double half-add is skipped
    # when |v| is integral; M_1235: the image is truncated at d). Every
    # one-change variant adds its flag on top of that baseline, so each
    # row is "ported rule, one thing changed". The historical
    # approximation (round_alg first, no halfskipint) is kept for
    # contrast and is NOT the ported rule.
    BASELINE={'halfskipint':1}
    def ported(**kv):
        d=dict(BASELINE); d.update(kv); return d
    variants=[('baseline-ported',dict(BASELINE)),('no-ulp-lift',ported(nolift=1)),('round-half-even-image',ported(halfeven=1)),('unscale-multiply-reciprocal',ported(unscale='mul')),('lift-inside-Str-3arg',ported(str3lift=1)),('half-threshold-15-digit',ported(halfth=15)),('historical-str3-approximation',{'str3round':1})]
    for name,v in variants:
        t,m,f=run(dict(v))
        emit('%-28s match %4d / %d  (fails %d)'%(name,m,t,t-m))
    emit()
    t,m,fails=run(dict(BASELINE))
    emit()
    emit('# Counts explained: results.tsv and out.txt each carry 2242 lines,')
    emit('# one per oracle row. The simulator skips the 38 K/L rows (K and L')
    emit('# are the invalid-shape ERR rows and the macro rows; both are covered')
    emit('# by the compiled harness, not by value simulation), leaving 2204')
    emit('# rows. 18 of those rows yield no value verdict (their evaluation')
    emit('# raises in the simulator - the same rows the harness treats as ERR),')
    emit('# leaving 2186 verdicts over 2090 DISTINCT case IDs: 96 O-section')
    emit('# IDs appear twice in results.tsv because each O case is evaluated')
    emit('# twice with the same expression and SET - once for the formatted N')
    emit('# row and once for the raw hb_CStr row; 2090 evaluated + 18')
    emit('# no-verdict = 2108 distinct non-K/L IDs, 2186 = 2090 + 96 second')
    emit('# verdicts. Verdicts are per evaluation, so both lines of an O pair')
    emit('# are scored separately.')
    emit('# Because both lines of each O pair are scored, the 96 O-section')
    emit('# pairs WEIGH TWICE in every variant score above - each score is')
    emit('# per evaluation, not per distinct case.')
    emit('#')
    emit('# baseline per-case verdicts: case-id | expression | MATCH/FAIL')
    for cid,expr,ok in run.results:
        emit('%s|%s|%s'%(cid,expr,'MATCH' if ok else 'FAIL'))
    if log: w.close()
