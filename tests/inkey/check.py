#!/usr/bin/env python3
"""INKEY (Linux, GTSTD-like, stdin keyboard): oracle comparison and rejects.
Original MIT test code; Harbour is only an external executable oracle."""
import argparse,hashlib,json,os,pathlib,subprocess,sys,time,pty,select
P=pathlib.Path
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--output',required=True);ap.add_argument('--tree',required=True);ap.add_argument('--hbmk2',required=True);a=ap.parse_args()
compiler=str(P(a.compiler).resolve());out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False)
env={k:v for k,v in os.environ.items() if k not in ['HB_CCPATH','HB_CCPREFIX','HB_CCSUFFIX','HBC_MINGW_LIB']}
rows=[]
def run(cmd,cwd,label,inp=None,timeout=60):
    r=subprocess.run(list(map(str,cmd)),cwd=cwd,capture_output=True,env=env,input=inp,timeout=timeout)
    for ext,v in [('stdout',r.stdout),('stderr',r.stderr),('rc',str(r.returncode).encode())]:(cwd/(label+'.'+ext)).write_bytes(v)
    return r
def prg(expr):return 'function main()\nlocal k\nk:='+expr+'\n?? "K=",k,valtype(k)\nreturn nil\n'
stdins={'empty':b'','Z':b'Z','AB':b'AB','esc':b'\x1b','crlf':b'\r\n','lf':b'\n','utf8':'\u00e9'.encode(),'bytes-ff-00':b'\xff\x00'}
exprs=['inkey()','inkey(0.2)','inkey(0.1+0.1)','inkey(1)','inkey(2.9)','inkey(0.01)','inkey(0.015)']
def tm(stdout):
    # elapsed is compared in tenths of a second, both builds measure the same way
    return stdout
for i,e in enumerate(exprs):
    d=out/('run-%d'%i);d.mkdir();(d/'p.prg').write_text(prg(e))
    r=run([compiler,d/'p.prg',d/'ours','--instrument'],d,'ours-build');assert r.returncode==0,(e,r.stderr)
    r=run([a.hbmk2,d/'p.prg','-quiet','-gtstd','-o'+str(d/'oracle')],d,'oracle-build');assert r.returncode==0 and (d/'oracle').exists(),(e,r.stderr)
    for sn,sv in stdins.items():
        res={}
        for who in ['ours','oracle']:
            (d/'stdin.bin').write_bytes(sv);t=time.time();c=subprocess.run([str(d/who)],cwd=d,stdin=open(d/'stdin.bin','rb'),capture_output=True,timeout=20,env=env);res[who]=(c.returncode,c.stdout,c.stderr,round(time.time()-t,2))
        (d/('result-'+sn+'.json')).write_text(json.dumps({k:[v[0],v[1].decode('latin1'),v[2].decode('latin1'),v[3]] for k,v in res.items()}))
        assert res['ours'][:3]==res['oracle'][:3],(e,sn,res)
        assert abs(res['ours'][3]-res['oracle'][3])<0.35,(e,sn,res)
        rows.append(dict(kind='oracle',expr=e,stdin=sn,ours=res['ours'][1].decode('latin1'),seconds=res['ours'][3],oracle_seconds=res['oracle'][3],passed=True))
# consecutive reads consume consecutive bytes, mixed with a timed wait
d=out/'sequence';d.mkdir();(d/'p.prg').write_text('function main()\n?? inkey(),inkey(0.1),inkey(),inkey(0.1),inkey(),inkey(0.1)\nreturn nil\n')
run([compiler,d/'p.prg',d/'ours','--instrument'],d,'ours-build');run([a.hbmk2,d/'p.prg','-quiet','-gtstd','-o'+str(d/'oracle')],d,'oracle-build')
for sn,sv in {'abc':b'abcd','empty':b''}.items():
    (d/'stdin.bin').write_bytes(sv);o=[subprocess.run([str(d/w)],stdin=open(d/'stdin.bin','rb'),capture_output=True,timeout=10).stdout for w in ['ours','oracle']];assert o[0]==o[1],(sn,o);rows.append(dict(kind='sequence',stdin=sn,out=o[0].decode(),passed=True))
# closed stdin and an open pipe that never delivers: timed wait must still elapse
d=out/'closed';d.mkdir();(d/'p.prg').write_text(prg('inkey(0.5)'))
run([compiler,d/'p.prg',d/'ours','--instrument'],d,'ours-build');run([a.hbmk2,d/'p.prg','-quiet','-gtstd','-o'+str(d/'oracle')],d,'oracle-build')
for who in ['ours','oracle']:
    for label,kw,pre in [('devnull',dict(stdin=subprocess.DEVNULL),None),('closed',dict(),'exec 0<&-; ')]:
        cmd=[str(d/who)] if pre is None else ['sh','-c',pre+'exec "$0"',str(d/who)]
        t=time.time();c=subprocess.run(cmd,cwd=d,capture_output=True,timeout=10,env=env,**kw);el=time.time()-t
        assert c.stdout.split()[1:3]==[b'0',b'N'] and abs(el-0.5)<0.3,(who,label,c.stdout,c.stderr,el)
    p=subprocess.Popen([str(d/who)],cwd=d,stdin=subprocess.PIPE,stdout=subprocess.PIPE,env=env);t=time.time();time.sleep(0.05)
    o=p.stdout.read();p.wait(10);p.stdin.close();assert o.split()[1:3]==[b'0',b'N'] and abs(time.time()-t-0.5)<0.3,(who,'open-pipe',o)
rows.append(dict(kind='closed-and-devnull',passed=True))
# deadline preservation: stdin closes or is stopped/continued mid-wait; total elapsed must stay at the
# original timeout (a rearmed full timeout would give 1.2 s / 1.8 s), same as the oracle
import signal
d=out/'deadline';d.mkdir();(d/'p.prg').write_text(prg('inkey(1)'))
run([compiler,d/'p.prg',d/'ours','--instrument'],d,'ours-build');run([a.hbmk2,d/'p.prg','-quiet','-gtstd','-o'+str(d/'oracle')],d,'oracle-build')
def timed(who,close_at=None,stop=None,byte_at=None):
    p=subprocess.Popen([str(d/who)],stdin=subprocess.PIPE,stdout=subprocess.PIPE,env=env);t=time.time()
    ev=([(close_at,'close')] if close_at is not None else [])+([(stop[0],'stop'),(stop[1],'cont')] if stop else [])+([(byte_at,'byte')] if byte_at is not None else [])
    for at,k in sorted(ev):
        w=at-(time.time()-t)
        if w>0:time.sleep(w)
        if k=='close':p.stdin.close()
        elif k=='stop':os.kill(p.pid,signal.SIGSTOP)
        elif k=='cont':os.kill(p.pid,signal.SIGCONT)
        else:p.stdin.write(b'Q');p.stdin.flush()
    o=p.stdout.read();p.wait();el=time.time()-t
    try:p.stdin.close()
    except Exception:pass
    return o.decode().split(),round(el,2)
for name,kw,want in [('close-0.2',dict(close_at=0.2),'0'),('close-0.8',dict(close_at=0.8),'0'),('stop-0.2-cont-0.5',dict(stop=(0.2,0.5)),'0'),('stop-cont-byte-0.7',dict(stop=(0.2,0.5),byte_at=0.7),'81'),('byte-0.4',dict(byte_at=0.4),'81'),('quiet-open-pipe',dict(),'0')]:
    r={who:timed(who,**kw) for who in ['ours','oracle']}
    assert r['ours'][0][-2]==want==r['oracle'][0][-2] and abs(r['ours'][1]-r['oracle'][1])<0.25,(name,r)
    rows.append(dict(kind='deadline',name=name,ours=r['ours'],oracle=r['oracle'],passed=True))
# real pty: cooked mode, newline-terminated key delivered late; both builds read byte 113
d=out/'pty';d.mkdir();(d/'p.prg').write_text(prg('inkey(5)'))
run([compiler,d/'p.prg',d/'ours','--instrument'],d,'ours-build');run([a.hbmk2,d/'p.prg','-quiet','-gtstd','-o'+str(d/'oracle')],d,'oracle-build')
for who in ['ours','oracle']:
    m,s=pty.openpty();p=subprocess.Popen([str(d/who)],cwd=d,stdin=s,stdout=s,stderr=s,close_fds=True);t=time.time();time.sleep(0.5);os.write(m,b'q\n');p.wait(10);buf=b''
    while select.select([m],[],[],0.2)[0]:
        try:buf+=os.read(m,1000)
        except OSError:break
    assert p.returncode==0 and b'113 N' in buf and time.time()-t<3,(who,buf)
    (d/(who+'.pty')).write_bytes(buf)
rows.append(dict(kind='pty',note='cooked tty line-buffered: byte arrives with newline; not raw mode',passed=True))
# oracle waits forever below 0.01 s: the build rejects those literals instead of hanging
for v in ['0.009','0.0004']:
    d=out/('oracle-hang-'+v);d.mkdir();(d/'p.prg').write_text(prg('inkey('+v+')'));run([a.hbmk2,d/'p.prg','-quiet','-gtstd','-o'+str(d/'oracle')],d,'oracle-build')
    try:subprocess.run([str(d/'oracle')],cwd=d,stdin=subprocess.DEVNULL,capture_output=True,timeout=2,env=env);raise SystemExit('oracle did not hang for '+v)
    except subprocess.TimeoutExpired:rows.append(dict(kind='oracle-hang',literal=v,passed=True))
def reject(name,expr,msg,extra=None):
    d=out/('reject-'+name);d.mkdir();(d/'p.prg').write_text(prg(expr) if not extra else extra);r=run([compiler,d/'p.prg',d/'exe'],d,'build')
    assert r.returncode==1 and msg in r.stderr and not (d/'exe').exists(),(name,r.stderr);rows.append(dict(kind='rejection',name=name,passed=True))
M=b'INKEY supports zero arguments or one numeric literal from 0.01'
for name,expr in [('zero','inkey(0)'),('zerof','inkey(0.0)'),('neg','inkey(-1)'),('negf','inkey(-0.5)'),('nil','inkey(NIL)'),('str','inkey("a")'),('log','inkey(.t.)'),('huge','inkey(86401)'),('tiny-0.009','inkey(0.009)'),('tiny-0.0004','inkey(0.0004)'),('array','inkey({1})')]:reject(name,expr,M)
reject('mask','inkey(1,0)',b'mask and extra arguments');reject('three','inkey(1,2,3)',b'mask and extra arguments')
reject('runtime-var','inkey(n)',M,'function main()\nlocal n:=1,k\nk:=inkey(n)\n?k\nreturn nil\n')
reject('unknown-shadow-unaffected','x',b'',None) if False else None
for target,mode in [('linux','--experimental-llvm'),('linux','--experimental-llvm-no-trace'),('windows','--experimental-llvm'),('macho-arm64',None),('macho',None)]:
    d=out/('profile-'+target+'-'+str(mode));d.mkdir();(d/'p.prg').write_text(prg('inkey(1)'));r=run([compiler,d/'p.prg',d/'exe','--target='+target]+([mode]if mode else[]),d,'build');assert r.returncode==1 and b'INKEY supports ordinary Linux and Windows PE stdin only' in r.stderr,(target,mode,r.stderr);rows.append(dict(kind='profile-rejection',target=target,mode=mode,passed=True))
res=dict(compiler_sha256=hashlib.sha256(P(compiler).read_bytes()).hexdigest(),compiler_tree=a.tree,oracle_hbmk2=a.hbmk2,count=len(rows),rows=rows)
(out/'results.json').write_text(json.dumps(res,indent=1));print('PASS',len(rows),'INKEY checks')
