import subprocess, pathlib, sys, json, os, hashlib
root = pathlib.Path(sys.argv[1])
tmp = pathlib.Path('/tmp/sweep-io'); tmp.mkdir(exist_ok=True)
def sh(cmd, timeout=20):
    fo = open(tmp/'o','wb'); fe = open(tmp/'e','wb')
    try:
        r = subprocess.run(cmd, cwd=root, stdout=fo, stderr=fe, timeout=timeout, stdin=subprocess.DEVNULL)
        rc = r.returncode
    except subprocess.TimeoutExpired:
        rc = 'TIMEOUT'
    fo.close(); fe.close()
    return rc, (tmp/'o').read_bytes(), (tmp/'e').read_bytes()
def build_linux(f, base):
    s = root/'gen'/(base+'.s'); o = root/'gen'/(base+'.o'); x = root/'gen'/base
    rc,_,_ = sh(['./hbc', f, str(s), '--target=linux', '--instrument', '-I', 'tests'])
    if rc != 0: return None
    if subprocess.run(['as','-o',str(o),str(s)], capture_output=True).returncode != 0: return None
    if subprocess.run(['ld','-o',str(x),str(o)], capture_output=True).returncode != 0: return None
    return x
def exp_esc(txt):
    return subprocess.run(['printf','%b',txt], capture_output=True).stdout.rstrip(b'\n')
rows = []
detail = {}
def rec(f, status, rc=None, out=None, err=None):
    rows.append((f, status))
    detail[f] = {'status': status, 'rc': rc,
                 'stdout_sha256': hashlib.sha256(out).hexdigest() if out is not None else None,
                 'stderr_sha256': hashlib.sha256(err).hexdigest() if err is not None else None}
for line in (root/'tests/manifest.txt').read_text().splitlines():
    if not line.strip() or line.startswith('#'): continue
    parts = line.split(' ')
    kind = parts[0]; f = parts[1]
    try:
        if kind in ('pos','posx'):
            base = pathlib.Path(f).stem
            if kind=='pos':
                # an empty-expectation pos row has no third field (e.g.
                # t747_set_decimals.prg): its expected stdout is empty
                seg = line.split(' ',2)
                want = exp_esc(seg[2]) if len(seg) > 2 else b''; wantrc = None
            else: wantrc = int(parts[2]); want = exp_esc(line.split(' ',3)[3])
            x = build_linux(f, base)
            if not x: rec(f,'BUILD-FAIL'); continue
            rc, out, err = sh([str(x)], 15)
            ok = (wantrc is None and rc == 0 or rc == wantrc) and out.rstrip(b'\n') == want and err == b''
            rec(f, 'PASS' if ok else 'FAIL', rc, out, err)
        elif kind == 'neg':
            sub = line.split(' ',2)[2]
            rc, o, e = sh(['./hbc', f, 'gen/neg.s', '--target=linux'])
            ok = rc == 1 and sub.encode() in (o + e)
            rec(f, 'PASS' if ok else 'FAIL(%s)'%rc, rc, o, e)
        elif kind == 'pos2':
            lexp = (root/parts[2]).read_bytes(); base = pathlib.Path(f).stem
            x = build_linux(f, base)
            if not x: rec(f,'BUILD-FAIL'); continue
            rc, o, e = sh([str(x)], 15)
            rec(f, 'PASS' if (rc == 0 and o == lexp and e == b'') else 'FAIL', rc, o, e)
        elif kind == 'streams':
            sexp = (root/parts[2]).read_bytes(); eexp = (root/parts[3]).read_bytes()
            x = build_linux(f, pathlib.Path(f).stem)
            if not x: rec(f,'BUILD-FAIL'); continue
            rc, o, e = sh([str(x)], 15)
            rec(f, 'PASS' if (rc == 0 and o==sexp and e==eexp) else 'FAIL', rc, o, e)
        elif kind == 'streams2':
            lexp = (root/parts[2]).read_bytes(); eexp = (root/parts[4]).read_bytes()
            x = build_linux(f, pathlib.Path(f).stem)
            if not x: rec(f,'BUILD-FAIL'); continue
            rc, o, e = sh([str(x)], 15)
            rec(f, 'PASS' if (rc == 0 and o==lexp and e==eexp) else 'FAIL', rc, o, e)
        elif kind == 'posx2':
            wantrc = int(parts[2]); lexp = (root/parts[3]).read_bytes()
            x = build_linux(f, pathlib.Path(f).stem)
            if not x: rec(f,'BUILD-FAIL'); continue
            rc, o, e = sh([str(x)], 15)
            rec(f, 'PASS' if (rc==wantrc and o+e==lexp) else 'FAIL', rc, o, e)
        elif kind == 'cli':
            ef = (root/parts[1]).read_bytes()
            rc, o, e = sh(['./hbc'] + line.split(' ',2)[2].split())
            rec(f, 'PASS' if (rc==0 and e==b'' and o==ef) else 'FAIL', rc, o, e)
    except Exception as ex:
        rec(f, 'ERR:'+str(ex)[:60])
print(json.dumps(dict(rows)))
if len(sys.argv) > 2:
    hdr = {'compiler_sha256': hashlib.sha256((root/'hbc').read_bytes()).hexdigest(),
           'rows': len(detail)}
    pathlib.Path(sys.argv[2]).write_text(json.dumps({'_meta': hdr, **detail}, indent=1, sort_keys=True))
