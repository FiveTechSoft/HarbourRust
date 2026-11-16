#!/usr/bin/env python3
"""Bounded PE object/separator regression against captured Harbour GTSTD bytes.
The expected streams are immutable oracle captures, never normalized here.
"""
import argparse, hashlib, json, os, pathlib, subprocess, tempfile
P = pathlib.Path
ap = argparse.ArgumentParser(description=__doc__)
ap.add_argument('--compiler', required=True)
ap.add_argument('--wine', help='omit on real Windows')
ap.add_argument('--cc', help='optional clang cross compiler for external assembly')
ap.add_argument('--ld', help='optional MinGW linker (requires --cc and --libdir)')
ap.add_argument('--libdir')
a = ap.parse_args()
if any([a.cc,a.ld,a.libdir]) and not all([a.cc,a.ld,a.libdir]): ap.error('external assembly needs --cc, --ld and --libdir')
root = P(__file__).resolve().parent
repo = root.parents[2]
hbc = P(a.compiler).resolve()
work = P(tempfile.mkdtemp(prefix='hbc-object-separators.'))
print('Evidence:', work, flush=True)
env = os.environ.copy()
records=[]
def run(cmd,label):
    try:
        p = subprocess.run([str(x) for x in cmd],cwd=repo,env=env,capture_output=True,timeout=30)
    except subprocess.TimeoutExpired as e:
        p = subprocess.CompletedProcess(cmd,124,e.stdout or b'',(e.stderr or b'')+b'\nTIMEOUT\n')
    for suffix,data in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:
        (work/(label+'.'+suffix)).write_bytes(data)
    return p
for name in ['p_sep','matrix','mixed']:
    src = root.parent/'programs/p_sep.prg' if name=='p_sep' else root/(name+'.prg')
    for engine in ['internal']+(['external'] if a.cc else []):
        label=name+'-'+engine
        exe=work/(label+'.exe')
        dst=exe if engine=='internal' else work/(label+'.s')
        p=run([hbc,src,dst,'--target=windows','-I',repo/'tests'],label+'.compile')
        assert p.returncode==0,(label,'compile',p.stderr)
        if engine=='external':
            obj=work/(label+'.o')
            p=run([a.cc,'--target=x86_64-w64-mingw32','-c',dst,'-o',obj],label+'.assemble')
            assert p.returncode==0,(label,'assemble',p.stderr)
            p=run([a.ld,'-o',exe,obj,'-e','_start','--subsystem','console','-L'+a.libdir,'-lkernel32'],label+'.link')
            assert p.returncode==0,(label,'link',p.stderr)
        p=run(([a.wine] if a.wine else [])+[exe],label+'.run')
        ok=p.returncode==0 and p.stdout==(root/(name+'.windows.stdout')).read_bytes() and p.stderr==(root/(name+'.windows.stderr')).read_bytes()
        records.append({'case':label,'pass':ok,'rc':p.returncode})
        print(('PASS ' if ok else 'FAIL ')+label,flush=True)
        if not ok:
            print(f'actual rc={p.returncode} stdout={p.stdout!r} stderr={p.stderr!r}', flush=True)
        (work/'result.json').write_text(json.dumps({'compiler_sha256':hashlib.sha256(hbc.read_bytes()).hexdigest(),'records':records},indent=2))
assert all(r['pass'] for r in records),'stream or exit mismatch; inspect evidence'
