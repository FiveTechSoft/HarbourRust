#!/usr/bin/env python3
"""DELTA-printing balance guard + strict two-state parser, shared by
check.py (the gate) and selftest_emit_delta.py (the parser probes).

The guard patches an instrumented emit so that, after
hbc_persistent_cleanup / hbc_str_cache_flush, a nonzero
hbc_mem_allocs-hbc_mem_frees balance is written to stderr as
'DELTA=<dec>\n' before exit(99); zero balance prints nothing and the
program exits normally.
"""
import pathlib, re, subprocess, json
P = pathlib.Path

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


def classify_memdelta(rc, stderr, stdout, expected):
    """The ONLY two valid instrumented-run states (reviewer CATCH v3):
    (rc 0, stderr EMPTY, stdout == expected)   -> delta 0
    (rc 99, stderr fullmatch 'DELTA=<n>\\n',
     stdout == expected)                       -> delta n
    Anything else (early failure before the guard, segfault, unexpected
    rc, missing DELTA, extra stderr garbage, wrong stdout) is rejected:
    a missing DELTA never reads as delta 0."""
    m = re.fullmatch(rb'DELTA=(\d+)\n', stderr)
    out_ok = stdout == expected
    if rc == 0 and stderr == b'' and out_ok:
        delta, state_ok = 0, True
    elif rc == 99 and m is not None and out_ok:
        delta, state_ok = int(m.group(1)), True
    else:
        delta, state_ok = None, False
    return {'rc': rc, 'stderr': stderr.decode('utf-8', 'replace'),
            'stdout_match': out_ok, 'delta': delta, 'state_ok': state_ok}


def emit_delta(compiler, env, exe_src, work, expected, include_dirs=()):
    """Instrumented emit + DELTA guard; returns the classify_memdelta
    record of the run. Raw stdout/stderr/rc of every step land in work."""
    work = P(work)
    def run(cmd, label):
        cmd = list(map(str, cmd))
        (work / (label + '.command.json')).write_text(json.dumps(
            dict(argv=cmd, cwd=str(work.resolve()), stdin='DEVNULL'), indent=2) + '\n')
        r = subprocess.run(cmd, cwd=work, env=env,
                           capture_output=True, stdin=subprocess.DEVNULL, timeout=60)
        for k, v in [('stdout', r.stdout), ('stderr', r.stderr), ('rc', str(r.returncode).encode())]:
            (work / (label + '.' + k)).write_bytes(v)
        return r
    s = work / 'checked.s'
    r = run([compiler, str(P(exe_src).resolve()), s, '--target=linux', '--instrument', '--no-prune', *[arg for directory in include_dirs for arg in ('-I', str(directory))]], 'emit')
    assert r.returncode == 0, (exe_src, r.stderr)
    text = s.read_text()
    anchor = '    call hbc_persistent_cleanup\n    call hbc_str_cache_flush\n'
    assert text.count(anchor) == 1, 'anchor not unique'
    if '    call hbc_arena_flush\n' in text[text.index(anchor):text.index(anchor) + 200]:
        anchor += '    call hbc_arena_flush\n'
    s.write_text(text.replace(anchor, anchor + DELTA_GUARD))
    r = run(['as', '--64', '-o', work / 'checked.o', s], 'as'); assert r.returncode == 0, r.stderr
    r = run(['ld', '-s', '-o', work / 'checked', work / 'checked.o'], 'ld'); assert r.returncode == 0, r.stderr
    r = run([work / 'checked'], 'memdelta')
    return classify_memdelta(r.returncode, r.stderr, r.stdout, expected)
