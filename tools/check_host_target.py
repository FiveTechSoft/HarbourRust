#!/usr/bin/env python3
"""Check compiler-host target defaults on Linux and a Windows compiler under Wine.

Both compilers must be built from the same source. Wine is not real Windows.
No suffix guessing: only .s selects assembly; --target always overrides host.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--linux-compiler', required=True)
    p.add_argument('--windows-compiler', required=True)
    p.add_argument('--wine', required=True)
    p.add_argument('--wine-prefix', required=True)
    p.add_argument('--output', required=True)
    a = p.parse_args()
    compilers = {k: Path(v).resolve() for k, v in
                 [('linux', a.linux_compiler), ('windows', a.windows_compiler)]}
    env = dict(os.environ, WINEDEBUG='-all', WINEPREFIX=a.wine_prefix)
    rows = []
    def win(path):
        return 'Z:' + str(path).replace('/', '\\')
    def run(cmd):
        return subprocess.run(cmd, capture_output=True, timeout=20,
                              stdin=subprocess.DEVNULL, env=env)
    with tempfile.TemporaryDirectory(prefix='hbc-host-target-') as directory:
        root = Path(directory)
        source = root / 'host.prg'
        source.write_text('procedure main()\n#ifdef __PLATFORM__WINDOWS\n? "windows"\n#else\n? "linux"\n#endif\nreturn\n')
        for host, compiler in compilers.items():
            prefix = [str(compiler)] if host == 'linux' else [a.wine, str(compiler)]
            for bad_args in ([], ['--invalid-option']):
                r = run(prefix + bad_args)
                rows.append(dict(host=host, kind='usage', args=bad_args, rc=r.returncode,
                                 stderr=r.stderr.hex(), **{'pass': r.returncode == 2 and
                                 b'target defaults to the compiler host' in r.stderr}))
            for target_option in (None, 'linux', 'windows'):
                target = target_option or host
                for instrument in (False, True):
                    for suffix in ('', '.exe', '.s'):
                        output = root / ('probe' + suffix)
                        command = prefix + ([str(source), str(output)] if host == 'linux'
                                            else [win(source), win(output)])
                        if target_option:
                            command.append('--target=' + target_option)
                        if instrument:
                            command.append('--instrument')
                        r = run(command)
                        row = dict(host=host, target_option=target_option, target=target,
                                   instrument=instrument, suffix=suffix,
                                   compile_rc=r.returncode, compile_stdout=r.stdout.hex(),
                                   compile_stderr=r.stderr.hex(), **{'pass': False})
                        if r.returncode == 0 and output.exists():
                            data = output.read_bytes()
                            row['artifact_sha256'] = hashlib.sha256(data).hexdigest()
                            compared = bytearray(data)
                            # The PE writer stamps wall-clock seconds and its checksum.
                            # Retain the raw hash; normalize only these 8 header bytes.
                            if suffix != '.s' and data.startswith(b'MZ'):
                                pe = int.from_bytes(data[0x3c:0x40], 'little')
                                assert data[pe:pe + 4] == b'PE\0\0'
                                compared[pe + 8:pe + 12] = b'\0' * 4
                                compared[pe + 24 + 64:pe + 24 + 68] = b'\0' * 4
                            row['comparison_sha256'] = hashlib.sha256(compared).hexdigest()
                            if suffix == '.s':
                                row['pass'] = ('# target: ' + target).encode() in data
                            else:
                                magic = b'\x7fELF' if target == 'linux' else b'MZ'
                                row['format_ok'] = data.startswith(magic)
                                # A Windows writer cannot set a Unix executable bit.
                                if target == 'linux':
                                    output.chmod(0o755)
                                r = run(([a.wine] if target == 'windows' else []) + [str(output)])
                                row.update(rc=r.returncode, stdout=r.stdout.hex(), stderr=r.stderr.hex())
                                row['pass'] = row['format_ok'] and (r.returncode, r.stdout, r.stderr) == (0, b'\n' + target.encode(), b'')
                            output.unlink()
                        rows.append(row)
                        if not row['pass']:
                            print('FAIL', row)
    # A missing flag must match explicit host output (PE timestamp/checksum aside).
    matrix = [r for r in rows if 'suffix' in r]
    for host in compilers:
        for instrument in (False, True):
            for suffix in ('', '.exe', '.s'):
                pair = [r for r in matrix if r['host'] == host and
                        r['instrument'] == instrument and r['suffix'] == suffix and
                        r['target_option'] in (None, host)]
                identical = (len(pair) == 2 and all(r['pass'] for r in pair) and
                             pair[0].get('comparison_sha256') == pair[1].get('comparison_sha256'))
                rows.append(dict(host=host, kind='default-equals-explicit-host-pe-time-checksum-normalized',
                                 instrument=instrument, suffix=suffix, **{'pass': identical}))
    Path(a.output).write_text(json.dumps(dict(compilers={k: dict(path=str(v), sha256=hashlib.sha256(v.read_bytes()).hexdigest()) for k, v in compilers.items()}, rows=rows), indent=2) + '\n')
    print('PASS', sum(r['pass'] for r in rows), '/', len(rows))
    return 0 if all(r['pass'] for r in rows) else 1


if __name__ == '__main__':
    raise SystemExit(main())
