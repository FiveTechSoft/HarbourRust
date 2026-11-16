#!/usr/bin/env python3
"""F5 thread targets: same-source raw Harbour differential plus native/GAS parity.
Requires Linux x86-64, GNU as/ld, and official Harbour hbmk2 with -mt.
Every command, rc, stdout and stderr is retained. No normalization is used.
"""
from pathlib import Path
import argparse, subprocess, json, hashlib, sys

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--compiler',required=True)
    ap.add_argument('--hbmk2',required=True)
    ap.add_argument('--output',required=True)
    a=ap.parse_args()
    compiler=Path(a.compiler).resolve();hbmk2=Path(a.hbmk2).resolve()
    evidence=Path(a.output).resolve();evidence.mkdir(parents=True,exist_ok=False)
    root=Path(__file__).resolve().parent/'programs'
    results=[]
    limits={'block_variable':'first argument must be','stress':'first argument must be','name_literal_missing':'cannot infer the type'}
    def run(cmd,work,label,timeout=45):
        (work/(label+'.cmd.json')).write_text(json.dumps(list(map(str,cmd))))
        try:
            p=subprocess.run(list(map(str,cmd)),cwd=work,capture_output=True,timeout=timeout)
            rc,stdout,stderr=p.returncode,p.stdout,p.stderr
        except subprocess.TimeoutExpired as e:
            rc,stdout,stderr=124,e.stdout or b'',(e.stderr or b'')+b'\nrunner timeout\n'
        for k,v in [('stdout',stdout),('stderr',stderr),('rc',str(rc).encode())]:
            (work/(label+'.'+k)).write_bytes(v)
        return rc,stdout,stderr
    for src in sorted(root.glob('*.prg')):
        stem=src.stem;w=evidence/stem;w.mkdir()
        hb=w/'oracle';hr=w/'native';ext=w/'gas';asm=w/'program.s';obj=w/'program.o'
        builds=[run([hbmk2,'-mt','-gtstd','-w0','-o'+str(hb),src],w,'build-hb'),
                run([compiler,src,hr],w,'build-native'),
                run([compiler,src,asm],w,'build-asm')]
        if all(b[0]==0 for b in builds):
            builds += [run(['as','-o',obj,asm],w,'build-as')]
            if builds[-1][0]==0:builds += [run(['ld','-o',ext,obj],w,'build-ld')]
        built=len(builds)==5 and all(b[0]==0 for b in builds)
        if stem in limits:
            expected=limits[stem].encode()
            ok=builds[0][0]==0 and all(b[0]==1 and expected in b[2] for b in builds[1:])
            results.append({'name':stem,'kind':'inherited_compile_limit','build':False,'ok':ok})
            print(stem,'EXPECTED LIMIT' if ok else 'FAIL',flush=True)
            continue
        r=[]
        if built:
            r=[run([hb],w,'run-hb'),run([hr],w,'run-native'),run([ext],w,'run-gas')]
        ok=built and r[0]==r[1]==r[2] and r[0][0]==0
        results.append({'name':stem,'kind':'raw_differential','build':built,'ok':ok})
        print(stem,'PASS' if ok else 'FAIL',flush=True)
    (evidence/'identity.json').write_text(json.dumps({
        'compiler':str(compiler),'compiler_sha256':hashlib.sha256(compiler.read_bytes()).hexdigest(),
        'hbmk2':str(hbmk2),'hbmk2_sha256':hashlib.sha256(hbmk2.read_bytes()).hexdigest(),
        'oracle_commit':'694428e1c12f726675b19324d62167fa77d68185'},indent=2))
    (evidence/'results.json').write_text(json.dumps(results,indent=2))
    print('PASS',sum(r['ok'] for r in results),'/',len(results))
    return 0 if all(r['ok'] for r in results) else 1
if __name__=='__main__':sys.exit(main())
