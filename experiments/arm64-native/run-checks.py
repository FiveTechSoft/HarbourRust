"""Run from a COPY of this directory, never from the checkout itself.
Required: stable rustc, Python 3. Optional emulator checks: requirements-dev.txt.
LLVM oracle is optional and read only from LLVM_SHARED_LIBRARY.
"""
import argparse, subprocess, os, sys, json, hashlib, shutil
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--repo',type=Path,required=True);p.add_argument('--without-emulator',action='store_true');a=p.parse_args()
r=Path(__file__).resolve().parent;repo=a.repo.resolve();rustc=os.environ.get('RUSTC','rustc')
assert r!=repo/'experiments'/'arm64-native','Copy this experiment outside the checkout first'
assert hashlib.sha256((repo/'src'/'hbc.rs').read_bytes()).hexdigest()=='d1042495f27e1b4749bd391751b37fccdd56429b1068fae4229f9aededcb67ca','Frontend changed: review/rebase the isolated harness instead of patching an unknown version'
os.chdir(r)
def run(*cmd):subprocess.run(list(map(str,cmd)),check=True)
run(sys.executable,'derive-sha-constants.py')
run(sys.executable,'verify-prototypes.py','--rustc',rustc)
for name in ['arm64-code','arm64-writer']:
 run(rustc,'--edition=2021','--test','-O','-C','strip=symbols',name+'.rs','-o',name+'-tests')
 run(r/(name+'-tests'))
for name in ['writer-fixtures','runtime-fixtures']:
 run(rustc,'--edition=2021','-O','-C','strip=symbols',name+'.rs','-o',name)
run(r/'writer-fixtures','writer-layouts')
for f in (r/'writer-layouts').glob('layout-*'):
 if f.suffix=='.json':continue
 run(sys.executable,'check_reference.py',f)
if os.environ.get('LLVM_SHARED_LIBRARY'):run(sys.executable,'check-encodings.py')
if not a.without_emulator:
 run(rustc,'--edition=2021','-O','-C','strip=symbols',repo/'src'/'hbc.rs','-o','hbc-baseline')
 run(sys.executable,'make-compiler-probe.py',repo)
 run(sys.executable,'test-runtime.py')
 run(sys.executable,'check-runtime-linux.py')
 run(sys.executable,'test-scalar-battery.py')
 run(rustc,'--edition=2021','-O','-C','strip=symbols','trace-fixtures.rs','-o','trace-fixtures')
 run(r/'trace-fixtures',r/'trace-fixtures-out')
 run(sys.executable,'test-trace-runtime.py')
 run(sys.executable,'test-ast-trace.py')
 run(sys.executable,'test-pair-source.py')
 run(sys.executable,'test-mixed-source.py')
 run(sys.executable,'test-i64-transport.py')
 run(sys.executable,'test-i64-arithmetic.py')
 run(sys.executable,'test-i64-division.py')
 run(sys.executable,'test-numeric-result.py')
 for folder in ['trace-fixtures-out','ast-trace-cases','pair-source-cases','mixed-source-cases','i64-transport-cases','i64-arithmetic-cases','i64-division-cases','numeric-result-cases']:
  for f in (r/folder).glob('*.arm'):run(sys.executable,'check_reference.py',f)
 for f in (r/'scalar-battery').glob('*.arm'):run(sys.executable,'check_reference.py',f)
 # Independent parser is optional; it is not used by generation or our verifier.
 try:from macholib.MachO import MachO
 except ImportError:print('macholib extra parser not installed; independent standard-library verifier ran')
 else:
  for f in (r/'scalar-battery').glob('*.arm'):assert MachO(str(f)).headers[0].header.cputype==0x100000c
print('Finished isolated development checks. No macOS loader, kernel, native hardware or Apple security verdict was tested.')
