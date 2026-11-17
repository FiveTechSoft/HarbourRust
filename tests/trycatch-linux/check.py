#!/usr/bin/env python3
"""Persistent runtime gate for try/catch/finally + Break ownership (CATCH v2).

Sections:
A. Manifest pos2 rows (tests/try-catch/try_basic, try_noerror_finally,
   try_break_value, try_nested_crossfn): ours linux AND windows runs vs the
   pinned expectations (raw bytes), plus an explicit Harbour-oracle SHIM run
   (oracle/<stem>.prg, BEGIN SEQUENCE translation) whose stdout must equal
   the pinned linux expectation too. NOTE on the shim: fresh Harbour
   (pin 694428e1, GTSTD) routes a RAW array bound error to the interactive
   error system (alert 'Error BASE/1132 Bound error: array access / Quit'),
   never reaching RECOVER, and Throw() of an error object also engages
   errorsys; the shims therefore Break() an ErrorNew() whose description is
   the observed error text. Our compiler intercepts the bound error
   directly into CATCH - deliberate, documented here.
B. Manifest negatives (try_return_neg, try_exit_neg): our compiler must
   reject with the registered E0025 diagnostic (rc != 0, text recorded).
C. Break ownership rows (programs/break_call_str, break_call_float,
   break_send_str): ours byte-exact vs the oracle shim; linux runs also
   patched with the zero-balance guard (hbc_mem_allocs - hbc_mem_frees == 0
   after persistent cleanup + cache flush). break_send_str is exempt from
   the zero-balance ASSERT (object runtime retains its chunk/template pool,
   same exemption as module-static-owned 'methods'); its per-iteration
   delta was proven N-invariant (1 alloc at N=1, 500 and 1000).
D. Declared divergence (programs/break_array_deepcopy): catch-bound Dyn
   arrays are DEEP COPIES under the single-owner model: e[1]:=99 after
   catch does NOT write back to the source (ours: '1 99'; the aliasing
   oracle prints '99 99'). The gate asserts BOTH outputs against their own
   pins so the divergence is named and frozen, never an advertised alias.

Every run records rc + stderr in results.json; PASS requires rc 0 and
EMPTY stderr on both ours and the oracle shim.
"""
import argparse, hashlib, json, os, pathlib, re, subprocess, sys
P = pathlib.Path

MANIFEST = ["try_basic", "try_noerror_finally", "try_break_value", "try_nested_crossfn"]
NEG = {"try_return_neg": "E0025: invalid RETURN from within of SEQUENCE code",
       "try_exit_neg": "E0025: invalid EXIT from within of SEQUENCE code"}
OWN = ["break_call_str", "break_call_float", "break_send_str"]
BALANCE_ASSERT = {"break_call_str", "break_call_float"}

ap = argparse.ArgumentParser()
ap.add_argument('--compiler', required=True)
ap.add_argument('--hbmk2', required=True)
ap.add_argument('--output', required=True)
ap.add_argument('--wine', default=None)
ap.add_argument('--tree', default=None)
a = ap.parse_args()
gate = P(__file__).resolve().parent
root = gate.parent
out = P(a.output).resolve(); out.mkdir(parents=True, exist_ok=False)
compiler = str(P(a.compiler).resolve()); hbmk2 = str(P(a.hbmk2).resolve())
env = os.environ.copy(); env['LC_ALL'] = 'C.UTF-8'; env['WINEDEBUG'] = '-all'
# The linux-only Harbour oracle shim must not inherit the mingw cross
# environment (HB_CCPATH/HB_CCPREFIX/HBC_MINGW_LIB flip hbmk2's default
# target to a Windows PE link, which then fails on -ldl/-lrt/-lz).
env_oracle = {k: v for k, v in env.items()
              if k not in ('HB_CCPATH', 'HB_CCPREFIX', 'HBC_MINGW_LIB')}

def run(cmd, work, label, envx=None):
    r = subprocess.run(list(map(str, cmd)), cwd=work, env=envx or env,
                       capture_output=True, stdin=subprocess.DEVNULL, timeout=60)
    for k, v in [('stdout', r.stdout), ('stderr', r.stderr), ('rc', str(r.returncode).encode())]:
        (work / (label + '.' + k)).write_bytes(v)
    return r

def rec(r):
    return {'rc': None, 'stderr': None} if r is None else {
        'rc': r.returncode, 'stderr': r.stderr.decode('utf-8', 'replace')}

rows = []

def emit_balance(exe_src, work):
    """Patch instrumented asm with the zero-balance guard, as+ld, return exe."""
    s = work / 'checked.s'
    r = run([compiler, exe_src, s, '--target=linux', '--instrument', '--no-prune'], work, 'emit')
    assert r.returncode == 0, (exe_src, r.stderr)
    text = s.read_text()
    anchor = '    call hbc_persistent_cleanup\n    call hbc_str_cache_flush\n'
    assert text.count(anchor) == 1, 'anchor not unique'
    if '    call hbc_arena_flush\n' in text[text.index(anchor):text.index(anchor) + 200]:
        anchor += '    call hbc_arena_flush\n'
    guard = ('    mov hbc_mem_allocs(%rip), %rax\n    sub hbc_mem_frees(%rip), %rax\n'
             '    test %rax, %rax\n    je .Lprobe_zero\n'
             '    mov $60, %eax\n    mov $99, %edi\n    syscall\n.Lprobe_zero:\n')
    s.write_text(text.replace(anchor, anchor + guard))
    r = run(['as', '--64', '-o', work / 'checked.o', s], work, 'as'); assert r.returncode == 0, r.stderr
    r = run(['ld', '-s', '-o', work / 'checked', work / 'checked.o'], work, 'ld'); assert r.returncode == 0, r.stderr
    return work / 'checked'

DELTA_GUARD = ('    mov hbc_mem_allocs(%rip), %rax\n'
               '    sub hbc_mem_frees(%rip), %rax\n'
               '    test %rax, %rax\n'
               '    je .Lprobe_zero\n'
               '    lea -1(%rsp), %rsi\n'
               '    movb $10, (%rsi)\n'
               '    mov $10, %r9\n'
               '.Ldgt_loop:\n'
               '    xor %rdx, %rdx\n'
               '    div %r9\n'
               '    add $48, %dl\n'
               '    dec %rsi\n'
               '    mov %dl, (%rsi)\n'
               '    test %rax, %rax\n'
               '    jne .Ldgt_loop\n'
               '    dec %rsi\n    movb $61, (%rsi)\n'
               '    dec %rsi\n    movb $65, (%rsi)\n'
               '    dec %rsi\n    movb $84, (%rsi)\n'
               '    dec %rsi\n    movb $76, (%rsi)\n'
               '    dec %rsi\n    movb $69, (%rsi)\n'
               '    dec %rsi\n    movb $68, (%rsi)\n'
               '    mov %rsp, %rdx\n'
               '    sub %rsi, %rdx\n'
               '    mov $2, %edi\n'
               '    mov $1, %eax\n'
               '    syscall\n'
               '    mov $60, %eax\n'
               '    mov $99, %edi\n'
               '    syscall\n'
               '.Lprobe_zero:\n')

def emit_delta(exe_src, work):
    """Instrumented emit + DELTA-printing guard; returns run record with
    the measured balance delta parsed from stderr (0 when balanced)."""
    s = work / 'checked.s'
    r = run([compiler, exe_src, s, '--target=linux', '--instrument', '--no-prune'], work, 'emit')
    assert r.returncode == 0, (exe_src, r.stderr)
    text = s.read_text()
    anchor = '    call hbc_persistent_cleanup\n    call hbc_str_cache_flush\n'
    assert text.count(anchor) == 1, 'anchor not unique'
    if '    call hbc_arena_flush\n' in text[text.index(anchor):text.index(anchor) + 200]:
        anchor += '    call hbc_arena_flush\n'
    s.write_text(text.replace(anchor, anchor + DELTA_GUARD))
    r = run(['as', '--64', '-o', work / 'checked.o', s], work, 'as'); assert r.returncode == 0, r.stderr
    r = run(['ld', '-s', '-o', work / 'checked', work / 'checked.o'], work, 'ld'); assert r.returncode == 0, r.stderr
    r = run([work / 'checked'], work, 'memdelta')
    m = re.search(rb'DELTA=(\d+)', r.stderr)
    return r, (int(m.group(1)) if m else 0)

# A. manifest rows
for stem in MANIFEST:
    work = out / stem; work.mkdir()
    src = root / 'try-catch' / (stem + '.prg')
    shim = gate / 'oracle' / (stem + '.prg')
    pin_lin = (root / 'expectations' / 'qout' / (stem + '.linux.out')).read_bytes()
    pin_win = (root / 'expectations' / 'qout' / (stem + '.windows.out')).read_bytes()
    b = run([compiler, src, work / stem, '--target=linux'], work, 'hbc-build')
    rl = run([work / stem], work, 'hbc-linux') if b.returncode == 0 else None
    ob = run([hbmk2, shim, '-gtstd', '-o' + stem + '_orc'], work, 'oracle-build', env_oracle)
    orun = run([work / (stem + '_orc')], work, 'oracle', env_oracle) if ob.returncode == 0 else None
    row = {'test': stem, 'kind': 'manifest-pos2',
           'ours_build_rc': b.returncode, 'oracle_build_rc': ob.returncode,
           'ours_linux': rec(rl), 'oracle_shim': rec(orun)}
    ok = (rl is not None and orun is not None and rl.returncode == 0 and orun.returncode == 0
          and rl.stderr == b'' and orun.stderr == b''
          and rl.stdout == pin_lin and orun.stdout == pin_lin)
    if a.wine:
        wb = run([compiler, src, work / (stem + '.exe'), '--target=windows'], work, 'hbc-build-win')
        wr = run([a.wine, work / (stem + '.exe')], work, 'hbc-windows') if wb.returncode == 0 else None
        row['ours_build_win_rc'] = wb.returncode; row['ours_windows'] = rec(wr)
        ok = ok and wr is not None and wr.returncode == 0 and wr.stderr == b'' and wr.stdout == pin_win
    row['pass'] = ok
    rows.append(row); print(('PASS' if ok else 'FAIL'), stem, 'manifest')

# B. negatives
for stem, diag in NEG.items():
    work = out / stem; work.mkdir()
    src = root / 'try-catch' / (stem + '.prg')
    b = run([compiler, src, work / stem, '--target=linux'], work, 'hbc-build')
    err = b.stderr.decode('utf-8', 'replace')
    ok = b.returncode != 0 and diag in err
    rows.append({'test': stem, 'kind': 'manifest-neg', 'pass': ok,
                 'expected_diag': diag, 'ours_build': rec(b)})
    print(('PASS' if ok else 'FAIL'), stem, 'negative')

# C+D. ownership rows
for stem in OWN + ['break_array_deepcopy']:
    work = out / stem; work.mkdir()
    src = gate / 'programs' / (stem + '.prg')
    shim = gate / 'oracle' / (stem + '.prg')
    b = run([compiler, src, work / stem, '--target=linux'], work, 'hbc-build')
    rl = run([work / stem], work, 'hbc-linux') if b.returncode == 0 else None
    ob = run([hbmk2, shim, '-gtstd', '-o' + stem + '_orc'], work, 'oracle-build', env_oracle)
    orun = run([work / (stem + '_orc')], work, 'oracle', env_oracle) if ob.returncode == 0 else None
    row = {'test': stem, 'ours_build_rc': b.returncode, 'oracle_build_rc': ob.returncode,
           'ours_linux': rec(rl), 'oracle_shim': rec(orun)}
    if stem == 'break_array_deepcopy':
        row['kind'] = 'declared-divergence'
        exp_ours = (gate / 'expected' / (stem + '.ours.out')).read_bytes()
        exp_orc = (gate / 'expected' / (stem + '.oracle.out')).read_bytes()
        ok = (rl is not None and orun is not None and rl.returncode == 0 and orun.returncode == 0
              and rl.stderr == b'' and orun.stderr == b''
              and rl.stdout == exp_ours and orun.stdout == exp_orc)
        row['declared'] = ('catch-bound Dyn arrays are deep copies (single-owner): '
                           'cell writes through the catch variable do not alias the source')
    else:
        row['kind'] = 'break-ownership'
        exp = (gate / 'expected' / (stem + '.out')).read_bytes()
        ok = (rl is not None and orun is not None and rl.returncode == 0 and orun.returncode == 0
              and rl.stderr == b'' and orun.stderr == b''
              and rl.stdout == exp and orun.stdout == exp)
        if stem in BALANCE_ASSERT:
            exe = emit_balance(src, work)
            mr = run([exe], work, 'memcheck')
            row['memcheck'] = rec(mr)
            ok = ok and mr.returncode == 0 and mr.stderr == b'' and mr.stdout == exp
        else:
            # Send row: MEASURED bound/baseline, not an exemption. The
            # object runtime retains a constant baseline (template pool);
            # measured delta = 2 at N=1, 500 and 1000 iterations, with AND
            # without Break (control program break_send_control: same class,
            # same method calls, no try/Break). Assert the Break run adds no
            # retention over the control and stays within the measured
            # constant bound; a per-iteration leak breaks both at N=500.
            SEND_BOUND = 2  # measured constant maximum (N=1/500/1000, break and control)
            br, bdelta = emit_delta(src, work)
            ctl_src = gate / 'programs' / 'break_send_control.prg'
            (work / 'control').mkdir()
            cr, cdelta = emit_delta(ctl_src, work / 'control')
            row['memdelta_break'] = {'delta': bdelta, 'rc': br.returncode}
            row['memdelta_control'] = {'delta': cdelta, 'rc': cr.returncode}
            row['memdelta_bound'] = SEND_BOUND
            ok = ok and bdelta <= SEND_BOUND and bdelta == cdelta
    row['pass'] = ok
    rows.append(row); print(('PASS' if ok else 'FAIL'), stem, row['kind'])

(out / 'results.json').write_text(json.dumps(
    {'compiler_sha256': hashlib.sha256(P(compiler).read_bytes()).hexdigest(),
     'compiler_tree': a.tree, 'rows': rows}, indent=2) + '\n')
assert all(r['pass'] for r in rows), 'see evidence'
