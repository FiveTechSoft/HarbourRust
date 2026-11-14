#!/usr/bin/env python3
"""Same-source SubStr allocation/copy benchmark, separate from regression manifest.

Process time includes launch/shutdown. Small short-running samples are noisy.
No runtime or library-wide speedup claim follows from these synthetic loops.
"""
import argparse
import json
import statistics
import subprocess
import time
from pathlib import Path

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--compiler', required=True, type=Path)
p.add_argument('--baseline', required=True, type=Path)
p.add_argument('--hbmk2', required=True, type=Path)
p.add_argument('--output', required=True, type=Path)
p.add_argument('--cc', default='cc')
a = p.parse_args()
a.output = a.output.resolve()
a.output.mkdir(parents=True, exist_ok=False)
a.compiler = a.compiler.resolve()
a.baseline = a.baseline.resolve()
a.hbmk2 = a.hbmk2.resolve()
rows = []


def run(cmd):
    return subprocess.run(list(map(str, cmd)), capture_output=True, timeout=60)


for size, iterations in [(8, 500000), (64, 500000), (256, 200000), (4096, 20000), (65536, 2000)]:
    src = a.output / ('copy-' + str(size) + '.prg')
    src.write_text('''function Main()
local source:=Replicate("A",SIZE)
local value:=Replicate("B",SIZE)
local total:=0
local i:=0
for i:=1 to ITERS
value:=SubStr(source,1,SIZE)
 total:=total+Len(value)+Asc(value)
next
? total
return nil
'''.replace('SIZE', str(size)).replace('ITERS', str(iterations)))
    csrc = src.with_suffix('.c')
    csrc.write_text('''#include <stdlib.h>
#include <string.h>
#include <stdio.h>
__attribute__((noinline)) static char *copy(const char *s,size_t n) {
 char *p=malloc(n); if(!p) exit(2); memcpy(p,s,n); return p;
}
int main(void) {
 size_t n=SIZE; char *s=malloc(n),*v=malloc(n); long long total=0;
 if(!s || !v) return 2; memset(s,'A',n); memset(v,'B',n);
 for(int i=0;i<ITERS;i++) {char *p=copy(s,n); free(v);v=p;total+=n+(unsigned char)v[0];}
 printf("\\n%10lld",total);free(v);free(s);return 0;
}
'''.replace('SIZE', str(size)).replace('ITERS', str(iterations)))
    expected = None
    for impl, compiler in [('baseline', a.baseline), ('candidate', a.compiler), ('Harbour', a.hbmk2), ('C_malloc_memcpy', a.cc)]:
        exe = a.output / (str(size) + '-' + impl)
        cmd = ([compiler, src, '-quiet', '-gtstd', '-o' + str(exe)] if impl == 'Harbour'
               else [compiler, '-O2', csrc, '-o', exe] if impl == 'C_malloc_memcpy'
               else [compiler, src, exe])
        q = run(cmd)
        assert q.returncode == 0, (impl, q.stdout, q.stderr)
        samples = []
        for _ in range(3):
            start = time.perf_counter_ns()
            q = run([exe])
            samples.append((time.perf_counter_ns() - start) / 1e9)
            assert q.returncode == 0 and not q.stderr, (impl, q.returncode, q.stderr)
            if expected is None:
                expected = q.stdout
            assert q.stdout == expected, (impl, q.stdout, expected)
        median = statistics.median(samples)
        row = {'bytes': size, 'iterations': iterations, 'implementation': impl,
               'seconds': samples, 'median_ns_per_call': median * 1e9 / iterations,
               'logical_MB_per_second': size * iterations / median / 1000000,
               'stdout_hex': expected.hex()}
        rows.append(row)
        print(impl, size, round(row['median_ns_per_call'], 2), 'ns/call', flush=True)
    (a.output / 'results.json').write_text(json.dumps(rows, indent=2) + '\n')
