#!/usr/bin/env python3
"""Dyn+Dyn runtime '+': oracle byte comparison, context regression, memory, rejects."""
import argparse,pathlib,subprocess,json,hashlib,os,sys
P=pathlib.Path;ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--hbmk2',required=True);ap.add_argument('--tree',required=True);ap.add_argument('--output',required=True);a=ap.parse_args()
gate=P(__file__).resolve().parent;out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False);compiler=str(P(a.compiler).resolve());env=os.environ.copy();env['LC_ALL']='C.UTF-8'
sys.path.insert(0,str(gate.parent/'trycatch-linux'));from memdelta_guard import emit_delta
rows=[]
def raw(cmd,w,label):
 p=subprocess.run(list(map(str,cmd)),cwd=w,capture_output=True,env=env,stdin=subprocess.DEVNULL,timeout=60)
 for k,v in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
 return p
def add(name,kind,ok,**kw):
 rows.append(dict(test=name,kind=kind,pass_=bool(ok),**kw));print('PASS' if ok else 'FAIL',name,flush=True)
def oracle(s):
 lines=s.splitlines();start=next(i for i,l in enumerate(lines) if l.lower().startswith('function main()'))+1
 while start<len(lines) and lines[start].strip().lower().startswith('local '):start+=1
 lines.insert(start,'ErrorBlock({|err| Break(err)})');s='\n'.join(lines)+'\n'
 return s.replace('try\n','begin sequence\n').replace('catch e\n','recover using e\n').replace('\nend\n','\nend sequence\n')
def both(src,w,kind):
 w.mkdir();o=w/'oracle.prg';o.write_text(oracle(src.read_text()))
 b=raw([a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(w/'oracle'),o],w,'oracle-build');q=raw([w/'oracle'],w,'oracle-run') if b.returncode==0 else None
 c=raw([compiler,src,w/'ours'],w,'ours-build');r=raw([w/'ours'],w,'ours-run') if c.returncode==0 else None
 return q,c,r
for kind in ['programs','context']:
 for src in sorted((gate/kind).glob('*.prg')):
  q,c,r=both(src,out/(kind+'-'+src.stem),kind)
  ok=q is not None and q.returncode==0 and r is not None and r.returncode==0 and r.stdout==q.stdout and r.stderr==b''
  add(kind+'-'+src.stem,'byte-exact-oracle' if kind=='programs' else 'context-regression-vs-oracle',ok)
for src in sorted((gate/'rejects').glob('*.prg')):
 w=out/('reject-'+src.stem);w.mkdir();c=raw([compiler,src,w/'exe'],w,'build')
 add('reject-'+src.stem,'named-rejection',c.returncode==1 and b'error: line' in c.stderr and not (w/'exe').exists(),stderr=c.stderr.decode()[:120])
# CHECKED_I64 functions (STATIC/@): Dyn+Dyn integer overflow must stop, never wrap
for nm,src_t in [('static-overflow','function main()\nlocal a,b\nstatic z := 0\na := 9223372036854775807\nb := 1\n? a+b\nreturn nil\n')]:
 w=out/nm;w.mkdir();(w/'p.prg').write_text(src_t);c=raw([compiler,w/'p.prg',w/'ours'],w,'build');r=raw([w/'ours'],w,'run') if c.returncode==0 else None
 add(nm,'checked-i64-overflow',r is not None and b'Limit: integer overflow needs numeric promotion' in r.stdout+r.stderr and b'-9223372036854775808' not in r.stdout)
# float Dyn: the former known limit (a*b, 1.5 * 2) is now the positive byte-exact programs/float-dyn.prg row above
shapes={
'assign':('d := "pp"\ne2 := "qq"','s := d+e2',False),
'accum':('d := "pp"\ne2 := "qq"','s := s+d+e2',False),
'int-add':('d := 2\ne2 := 3','s := d+e2',False),
'mixed-err':('d := "p"\ne2 := 1','s := d+e2',True),
'nil-err':('d := "p"\ne2 := NIL','s := d+e2',True),
'chain-int-err':('d := "p"\ne2 := "q"','s := d+e2+1',True),
'chain-int-err-left':('d := "p"\ne2 := "q"','s := 1+d+e2',True),
'chain-str-lit':('d := "p"\ne2 := "q"','s := d+e2+"z"',False),
'chain-int-ok':('d := 2\ne2 := 3','s := d+e2+1',False),
'rhs-break':('d := "pp"\ne2 := "qq"','s := d+boom()',True),
}
for name,(init,body,caught) in shapes.items():
 for n in [1,500,1000]:
  vals={}
  for control in [False,True]:
   w=out/('mem-'+name+'-'+str(n)+('-control' if control else '-actual'));w.mkdir();src=w/'probe.prg'
   s='function main()\nlocal d,e2,e,i,s,hits := 0\nfor i:=1 to '+str(n)+'\ns := ""\n'+init+'\n'
   if control:s+='if .f.\n'
   s+='try\n'+body+'\ncatch e\nhits += 1\nend\n'
   if control:s+='endif\n'
   s+='e := NIL\nnext\n? hits\nreturn nil\nfunction boom()\nbreak("boom")\nreturn "never"\n'
   src.write_text(s);expected=b'\n'+f'{n if caught and not control else 0:10d}'.encode()
   try:r=emit_delta(compiler,env,src,w,expected)
   except Exception as ex:r=dict(state_ok=False,delta=None,error=str(ex))
   vals['control' if control else 'actual']=r
  add('mem-'+name+'-'+str(n),'memory-control',all(v.get('state_ok') and v.get('delta')==0 for v in vals.values()),bound=0,states=vals)
ident=dict(compiler_tree=a.tree,compiler_sha256=hashlib.sha256(P(compiler).read_bytes()).hexdigest(),scope='Linux runtime, external Harbour 3.2.1dev oracle',total=len(rows),passed=sum(x['pass_'] for x in rows),rows=rows);(out/'results.json').write_text(json.dumps(ident,indent=2));sys.exit(0 if ident['total']==ident['passed'] else 1)
