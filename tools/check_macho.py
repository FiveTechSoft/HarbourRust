#!/usr/bin/env python3
"""Compile-only Mach-O structure audit. This never executes a Mac program.

Run from the repository root. Optional macholib gives an independent parser.
Compiler acceptance and structure are NOT language/runtime compatibility.
"""
import argparse
import hashlib
import json
from pathlib import Path
import struct
import subprocess
import tempfile
import time


def validate(data):
    if len(data) < 4096:
        raise ValueError('image shorter than one page')
    magic, cpu, subtype, kind, count, size, flags, reserved = struct.unpack_from('<8I', data)
    if (magic, cpu, subtype, kind, flags, reserved) != (0xfeedfacf, 0x01000007, 3, 2, 1, 0):
        raise ValueError('unexpected Intel static Mach-O header')
    if count > 64 or 32 + size > 4096:
        raise ValueError('load command bound')
    offset = 32
    segments = []
    entry = None
    for _ in range(count):
        cmd, length = struct.unpack_from('<II', data, offset)
        if length < 8 or length % 8 or offset + length > 32 + size:
            raise ValueError('load command length')
        if cmd == 0x19:
            if length != 72:
                raise ValueError('unexpected segment sections')
            name, va, ms, off, fs, maximum, initial, sections, attributes = struct.unpack_from('<16sQQQQIIII', data, offset + 8)
            name = name.rstrip(b'\0').decode('ascii')
            if any(x % 4096 for x in (va, ms, off, fs)) or fs > ms or off + fs > len(data):
                raise ValueError('segment range/alignment')
            if initial != maximum or initial not in (0, 1, 3, 5) or sections or attributes:
                raise ValueError('segment protection/metadata')
            segments.append(dict(name=name, va=va, memory_size=ms, file_offset=off,
                                 file_size=fs, permissions=initial))
        elif cmd == 5:
            if length != 184 or entry is not None:
                raise ValueError('thread command count/size')
            flavor, words = struct.unpack_from('<II', data, offset + 8)
            regs = struct.unpack_from('<21Q', data, offset + 16)
            if flavor != 4 or words != 42:
                raise ValueError('x86_THREAD_STATE64 flavor/count')
            entry = regs[16]
        else:
            raise ValueError('unexpected load command')
        offset += length
    if offset != 32 + size or entry is None:
        raise ValueError('commands do not fill sizeofcmds or lack entry')
    zero = [s for s in segments if s['name'] == '__PAGEZERO']
    if len(zero) != 1 or zero[0]['va'] != 0 or zero[0]['permissions'] or zero[0]['memory_size'] < 4096:
        raise ValueError('missing guard mapping')
    if not any(s['permissions'] == 5 and s['va'] <= entry < s['va'] + s['file_size'] for s in segments):
        raise ValueError('entry outside executable file bytes')
    for i, a in enumerate(segments):
        for b in segments[i + 1:]:
            if a['va'] < b['va'] + b['memory_size'] and b['va'] < a['va'] + a['memory_size']:
                raise ValueError('overlapping virtual segments')
    return dict(entry=entry, segments=segments)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--compiler', required=True)
    ap.add_argument('--manifest', default='tests/manifest.txt')
    ap.add_argument('--output', required=True)
    ap.add_argument('--macholib', action='store_true')
    ap.add_argument('--budget', type=int, default=0, help='stop after this many seconds; resume with identical inputs')
    a = ap.parse_args()
    if a.macholib:
        from macholib.MachO import MachO
    compiler = Path(a.compiler).resolve()
    checkpoint = Path(a.output + '.jsonl')
    state_path = Path(a.output + '.state')
    state = dict(compiler_sha256=hashlib.sha256(compiler.read_bytes()).hexdigest(),
                 manifest_sha256=hashlib.sha256(Path(a.manifest).read_bytes()).hexdigest())
    if state_path.exists() and json.loads(state_path.read_text()) != state:
        raise SystemExit('Checkpoint inputs changed; choose a new output path')
    state_path.write_text(json.dumps(state))
    rows = [json.loads(line) for line in checkpoint.read_text().splitlines()] if checkpoint.exists() else []
    done = {r['index'] for r in rows}
    started = time.monotonic()
    complete = True
    with tempfile.TemporaryDirectory(prefix='hbc-macho-structure-') as scratch:
        exe = Path(scratch) / 'program'
        for index, line in enumerate(Path(a.manifest).read_text().splitlines()):
            if not line or line.startswith('#'):
                continue
            if index in done:
                continue
            if a.budget and time.monotonic() - started >= a.budget:
                complete = False
                break
            kind, source, *rest = line.split(' ', 2)
            spec = rest[0] if rest else ''
            row = dict(index=index, kind=kind, source=source,
                       source_sha256=hashlib.sha256(Path(source).read_bytes()).hexdigest())
            exe.unlink(missing_ok=True)
            p = subprocess.run([str(compiler), source, str(exe), '--target=macho', '--instrument']
                               + (['-I', 'tests'] if kind != 'neg' else []),
                               capture_output=True, timeout=30)
            row.update(compile_rc=p.returncode, compile_stdout=p.stdout.hex(), compile_stderr=p.stderr.hex())
            if p.returncode == 0:
                data = exe.read_bytes()
                row.update(structure=validate(data), artifact_sha256=hashlib.sha256(data).hexdigest(), structure_pass=True)
                if a.macholib:
                    m = MachO(str(exe))
                    assert len(m.headers) == 1 and m.headers[0].header.cputype == 0x01000007
                    row['independent_macholib_pass'] = True
                row['classification'] = 'emitted-structure-only-not-executed'
            else:
                row['classification'] = ('expected-language-rejection' if kind == 'neg' and spec.encode() in p.stderr
                                         else 'rejection-not-counted-as-pass')
            rows.append(row)
            with checkpoint.open('a') as sink:
                sink.write(json.dumps(row) + '\n')
    Path(a.output).write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(compiler.read_bytes()).hexdigest(),
        scope='compile-only; no macOS execution or compatibility claim', complete=complete, rows=rows)) + '\n')
    from collections import Counter
    print(dict(Counter(r['classification'] for r in rows)))
    print('Total sources:', len(rows), 'complete:', complete, '(not a runtime pass count)')


if __name__ == '__main__':
    main()
