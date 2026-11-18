#!/usr/bin/env python3
"""CATCH e where e is a PRIVATE/PUBLIC (MEMVAR) name.
The catch store wrote through a frame offset the memvar never has (offset 0), so the binary ended in SIGSEGV. The compiler now
refuses it at the CATCH line with a named diagnostic (the MEMVAR resolver is not implemented here).
(1) reject/*.prg: external oracle ACCEPTS the program (TRY converted to BEGIN SEQUENCE, prints the thrown value, rc 0);
    the compiler exits non-zero with the named diagnostic on stderr, empty stdout, and writes no output file (ELF, PE).
(2) control/*.prg: valid shapes (LOCAL catch variable, even when another function has a PRIVATE of the same name; PRIVATE declared
    after the CATCH) build and their stdout is byte-identical to the oracle on ELF internal, ELF external and PE/Wine (CRLF).
Original MIT; Harbour 3.2.1dev r2610242111 is only an external oracle (not Harbour 4)."""
import argparse,pathlib,subprocess,json,hashlib,os,re
P=pathlib.Path;ap=argparse.ArgumentParser()
for k in ['--compiler','--hbmk2','--output']:ap.add_argument(k,required=True)
a=ap.parse_args();gate=P(__file__).resolve().parent;out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False);cc=str(P(a.compiler).resolve())
env=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'],WINEDEBUG='-all',LC_ALL='C.UTF-8')
rows=[]
def add(n,k,ok,**kw):
    rows.append(dict(test=n,kind=k,pass_=bool(ok),**kw));print('PASS' if ok else 'FAIL',n,flush=True)
def sh(cmd,w,label):
    p=subprocess.run(list(map(str,cmd)),cwd=w,capture_output=True,env=env,stdin=subprocess.DEVNULL,timeout=120)
    for k,v in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
    return p
def oracle(s):
    lines=s.splitlines()
    for j,l in enumerate(lines):
        if l.lower().startswith('function main()'):
            j+=1
            while j<len(lines) and lines[j].strip().lower().startswith('local '):j+=1
            lines.insert(j,'ErrorBlock({|err| Break(err)})');break
    s='\n'.join(lines)+'\n'
    s=re.sub(r'^(\s*)try$',r'\1begin sequence',s,flags=re.M|re.I);s=re.sub(r'^(\s*)catch e$',r'\1recover using e',s,flags=re.M|re.I)
    return re.sub(r'^(\s*)end$',r'\1end sequence',s,flags=re.M|re.I)
def oracle_run(src,w):
    (w/'o.prg').write_text(oracle(src.read_text()))
    ob=sh([a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(w/'oracle'),w/'o.prg'],w,'oracle-build')
    return ob,(sh([w/'oracle'],w,'oracle-run') if ob.returncode==0 else None)
for src in sorted((gate/'reject').glob('*.prg')):
    w=out/('reject-'+src.stem);w.mkdir();(w/'p.prg').write_bytes(src.read_bytes())
    ob,orr=oracle_run(src,w);ok=orr is not None and orr.returncode==0 and len(orr.stdout)>0
    for who,cmd in [('elf',['p.prg','x-elf']),('pe',['p.prg','x-pe.exe','--target=windows'])]:
        c=sh([cc]+cmd,w,'build-'+who)
        ok=ok and c.returncode!=0 and b'is a PRIVATE/PUBLIC (MEMVAR) binding' in c.stderr and c.stdout==b'' and not (w/cmd[1]).exists()
    add('reject-'+src.stem,'oracle-accepts-compiler-named-rejection-no-output',ok)
for src in sorted((gate/'control').glob('*.prg')):
    w=out/('ctl-'+src.stem);w.mkdir();(w/'p.prg').write_bytes(src.read_bytes())
    ob,orr=oracle_run(src,w);ok=orr is not None and orr.returncode==0 and len(orr.stdout)>0
    for who,cmd,win in [('elf-int',['p.prg','x-elf-int'],False),('elf-ext',['p.prg','x-elf-ext','--external-as'],False),('pe',['p.prg','x-pe.exe','--target=windows'],True)]:
        c=sh([cc]+cmd,w,'build-'+who)
        if c.returncode!=0:ok=False;continue
        r=sh(['wine',w/'x-pe.exe'] if win else [w/('x-'+who)],w,'run-'+who)
        want=orr.stdout.replace(b'\n',b'\r\n') if win else orr.stdout
        ok=ok and r.returncode==0 and r.stdout==want and r.stderr==b''
    add('ctl-'+src.stem,'stdout-byte-identical-to-oracle',ok)
ident=dict(compiler_sha256=hashlib.sha256(P(cc).read_bytes()).hexdigest(),total=len(rows),passed=sum(r['pass_'] for r in rows))
(out/'results.json').write_text(json.dumps(dict(ident=ident,rows=rows),indent=1))
print('%d/%d'%(ident['passed'],ident['total']));raise SystemExit(0 if ident['passed']==ident['total'] else 1)
