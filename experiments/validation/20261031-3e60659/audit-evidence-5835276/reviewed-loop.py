attempt = 0
while True:
    attempt += 1
    result = subprocess.run(([env['WINE'], exe] if target == 'windows' else [exe]), capture_output=True, timeout=20)
    clean = result.returncode == want_rc and result.stderr == b''
    # Wine teardown flake (observed 2026-10-31 on t49_nested_loop,
    # windows/current): correct stdout and exit code, but the
    # wineserver reports a page fault while shutting the process
    # down. Retry up to 2 times and log each retry; a persistent
    # fault or any output/exit-code mismatch still fails the gate.
    if not clean and attempt < 3 and result.returncode == want_rc and b'starting debugger' in result.stderr:
        print('RETRY wine teardown noise', case, target, backend, 'attempt', attempt, flush=True)
        continue
    assert clean, (case, target, backend, result)
    break
if kind == 'posx':
    # Existing shell runner strips trailing newlines; retain its
    # expectation semantics, then require exact backend parity.
    assert result.stdout.rstrip(b'\n') == expected.rstrip(b'\n'), (case,target,backend,result.stdout,expected)
    if current_bytes is None:
        current_bytes = result.stdout
    else:
        assert result.stdout == current_bytes, (case,target,result.stdout,current_bytes)
else:
    assert result.stdout == expected, (case, target, backend, result.stdout, expected)
