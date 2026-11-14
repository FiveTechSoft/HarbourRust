#!/usr/bin/env python3
"""Assert exact v1 source cohort in the central manifest; new PRGs outside
that manifest do not change this count. Excluded/compile-off assembly must
have no I3 symbols/imports; a supplied pinned --baseline also proves byte
identity of assembly on both native targets for every compiling input.
"""
from pathlib import Path
import argparse,json,os,subprocess,tempfile,hashlib

def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--compiler',required=True);ap.add_argument('--baseline');ap.add_argument('--output',required=True);a=ap.parse_args()
    here=Path(__file__).resolve().parent;repo=here.parents[1];out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=True);compiler=Path(a.compiler).resolve();expected=set(json.loads((here/'cohort.json').read_text()));actual=set();rows=[]
    env=dict(os.environ,HBC_VAS_DUMP='1')
    sources=[l.split(' ',2)[1]for l in (repo/'tests/manifest.txt').read_text().splitlines()if l and not l.startswith('#')]
    for src in sources:
        p=subprocess.run([str(compiler),src,str(out/'new.s'),'-I','tests'],cwd=repo,capture_output=True,env=env);eligible=b'VAS eligible=true reasons='in p.stderr
        if eligible:actual.add(src)
        rows.append({'source':src,'eligible':eligible,'compile_rc':p.returncode})
        if p.returncode:continue
        for target in ['linux','windows']:
            if target=='windows':
                q=subprocess.run([str(compiler),src,str(out/'new.s'),'-I','tests','--target='+target],cwd=repo,capture_output=True)
                if q.returncode:continue
            new=(out/'new.s').read_bytes()
            q=subprocess.run([str(compiler),src,str(out/'off.s'),'-I','tests','--target='+target,'--no-vas-arrays'],cwd=repo,capture_output=True);assert not q.returncode,(src,target,q.stderr)
            off=(out/'off.s').read_bytes();assert b'hbc_vnew:'not in off and b'VirtualAlloc'not in off,(src,target,'compile-off contamination')
            if not eligible:assert new==off,(src,target,'excluded changed')
            if a.baseline:
                q=subprocess.run([str(Path(a.baseline).resolve()),src,str(out/'base.s'),'-I','tests','--target='+target],cwd=repo,capture_output=True);assert not q.returncode,(src,target,q.stderr)
                assert(out/'base.s').read_bytes()==off,(src,target,'baseline diff')
        # Restore Linux for next iteration (new.s is overwritten by compile).
    assert actual==expected,{'missing':sorted(expected-actual),'extra':sorted(actual-expected)}
    (out/'results.json').write_text(json.dumps({'cohort':sorted(actual),'total_manifest':len(rows),'rows':rows},indent=2)+'\n')
    for p in out.glob('*.s'):p.unlink()
    print('PASS exact cohort',len(actual),'of',len(rows),'; Linux/Windows exclusions and compile-off clean')
if __name__=='__main__':main()
