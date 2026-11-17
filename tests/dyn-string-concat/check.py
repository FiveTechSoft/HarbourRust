#!/usr/bin/env python3
"""Bounded Str/Dyn concatenation: fresh oracle, native images, live counters."""
import argparse,pathlib,subprocess,json,hashlib,os,sys
P=pathlib.Path;ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--hbmk2',required=True);ap.add_argument('--wine');ap.add_argument('--tree',required=True);ap.add_argument('--output',required=True);ap.add_argument('--stage',choices=['all','oracle','memory'],default='all');ap.add_argument('--write-pins',action='store_true');a=ap.parse_args()
gate=P(__file__).resolve().parent;out=P(a.output).resolve();out.mkdir(parents=True,exist_ok=False);compiler=str(P(a.compiler).resolve());env=os.environ.copy();env['LC_ALL']='C.UTF-8';env['WINEDEBUG']='-all';oe={k:v for k,v in env.items() if k not in ['HB_CCPATH','HB_CCPREFIX','HBC_MINGW_LIB']};rows=[]
def raw(cmd,w,label,ex=env):
 p=subprocess.run(list(map(str,cmd)),cwd=w,capture_output=True,env=ex,stdin=subprocess.DEVNULL,timeout=60)
 for k,v in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(w/(label+'.'+k)).write_bytes(v)
 return p
def add(name,kind,ok,**kw):
 rows.append(dict(test=name,kind=kind,pass_=bool(ok),**kw));print('PASS' if ok else 'FAIL',name,flush=True)
def oracle(s):
 lines=s.splitlines(); start=next(i for i,l in enumerate(lines) if l.lower().startswith(('function main()','procedure main()')))+1
 while start<len(lines) and lines[start].strip().lower().startswith('local '):start+=1
 lines.insert(start,'ErrorBlock({|err| Break(err)})');s='\n'.join(lines)+'\n'
 s=s.replace('try\n','begin sequence\n').replace('catch e\n','recover using e\n').replace('\nend\n','\nend sequence\n')
 return s
if a.stage in ['all','oracle']:
 for src in sorted((gate/'programs').glob('*.prg')):
  w=out/src.stem;w.mkdir();oracle_src=w/'oracle.prg';oracle_src.write_text(oracle(src.read_text()));b=raw([a.hbmk2,'-quiet','-gtstd','-w0','-o'+str(w/'oracle'),oracle_src],w,'oracle-build',oe);q=raw([w/'oracle'],w,'oracle',oe) if b.returncode==0 else None;good=q is not None and q.returncode==0 and q.stderr==b''
  for target in ['linux']+(['windows'] if a.wine else []):
   exe=w/target;b=raw([compiler,src,exe,'--target='+target],w,target+'-build');r=raw(([a.wine] if target=='windows' else [])+[exe],w,target) if b.returncode==0 else None
   expected=(q.stdout.replace(b'\n',b'\r\n') if target=='windows' else q.stdout) if q is not None else None
   pin=gate/'expected'/(src.stem+'.'+target+'.out')
   if a.write_pins and good and expected is not None:pin.write_bytes(expected)
   ok=good and r is not None and r.returncode==0 and r.stderr==b'' and r.stdout==expected and pin.exists() and pin.read_bytes()==expected
   add(src.stem+'-'+target,'byte-exact-oracle',ok,build_rc=b.returncode,run_rc=r.returncode if r else None)
sys.path.insert(0,str(gate.parent/'trycatch-linux'));from memdelta_guard import emit_delta
shapes={
'local-left':('d := "owned"','s := d+"!"',''),
'local-right':('d := "owned"','s := "!"+d',''),
'chain':('d := "owned"','s := d+"-"+d',''),
'retag-snapshot':('d := "owned"','s := d+(d:=2,"!")',''),
'string-rebind':('d := "unused"','s := s+change(@s)','function change(x)\nlocal d\nx := "changed"\nd := "!"\nreturn d\n'),
'self-dyn':('d := "owned"','d := d+"!"',''),
'grow':('d := "owned"','s := s+d',''),
'own-call':('','s := fresh()+"!"','function fresh()\nlocal d\nd := "owned"\nreturn d\n'),
'own-call-right':('','s := "!"+fresh()','function fresh()\nlocal d\nd := "owned"\nreturn d\n'),
'array-cell':('d := "unused"','s := a[1]+"!"',''),
'bad-nil':('d := NIL','s := Space(7)+d',''),
'bad-int-left':('d := 7','s := d+Space(7)',''),
'bad-int-right':('d := 7','s := Space(7)+d',''),
'bad-bool':('d := .t.','s := d+Space(7)',''),
'bad-float':('d := 1.25','s := Space(7)+d',''),
'bad-array-borrow':('d := {1,NIL}','s := Space(7)+d',''),
'bad-own-float':('','s := Space(7)+bad()','function bad()\nlocal d\nd := 1.25\nreturn d\n'),
'rhs-break':('d := "owned"','s := d+boom()','function boom()\nbreak("boom")\nreturn "never"\n'),
'rhs-bound':('d := "owned"','s := Space(7)+a[3]',''),
'rhs-nested':('d := "owned"','s := d+("x"+bad())','function bad()\nlocal d\nreturn d\n'),
}
if a.stage in ['all','memory']:
 for name,(init,expr,funcs) in shapes.items():
  for n in [1,500,1000]:
   vals={}
   for control in [False,True]:
    w=out/(name+'-'+str(n)+('-control' if control else '-actual'));w.mkdir();src=w/'probe.prg';caught=name.startswith('bad-') or name.startswith('rhs-');expected=b'\n'+f'{n if caught and not control else 0:10d}'.encode()
    s='function main()\nlocal d,e,i,s := Space(7),a := {"one",NIL},hits := 0\nfor i:=1 to '+str(n)+'\ns := Space(7)\n'+init+'\n'
    if control:s+='if .f.\n'
    s+=(expr+'\n') if name=='string-rebind' else ('try\n'+expr+'\ncatch e\nhits += 1\nend\n')
    if control:s+='endif\n'
    s+='e := NIL\ns := Space(7)\nnext\n? hits\nreturn nil\n'+funcs;src.write_text(s)
    try:r=emit_delta(compiler,env,src,w,expected)
    except Exception as e:r=dict(state_ok=False,delta=None,error=str(e))
    vals['control' if control else 'actual']=r
   add(name+'-'+str(n),'memory-control',all(v['state_ok'] and v['delta']==0 for v in vals.values()),bound=0,states=vals)
# DATA always clones; a computed owned source has no local slot that
# could free it. Exercise actual stores, not merely DATA reads in QOut.
if a.stage in ['all','memory']:
 header='#include "hbclass.ch"\nCREATE CLASS T\nDATA s INIT "ab"\nMETHOD New() CONSTRUCTOR\nENDCLASS\nMETHOD New() CLASS T\nreturn Self\n'
 forms={'self-left':'o:s+"cd"','self-right':'"cd"+o:s','nested':'o:s+"-"+o:s','local':'d+"!"','call':'fresh()+"!"','array':'xs[1]+"!"','variable':'v','static-concat':'"a"+Space(2)','builtin':'Space(7)'}
 for name,expr in forms.items():
  for n in [1,500,1000]:
   vals={}
   for control in [False,True]:
    w=out/('data-store-'+name+'-'+str(n)+('-control' if control else '-actual'));w.mkdir();src=w/'probe.prg'
    # Reset DATA each iteration to keep payload bounded and allocator
    # behavior comparable. Keep v live across stores to prove borrowing.
    s=header+'function exercise()\nlocal o := T():New(),i,d,v := Space(7),xs := {"cell",NIL}\nd := "owned"\nfor i:=1 to '+str(n)+'\no:s := "ab"\no:s := '+('"control"' if control else expr)+'\nnext\n? Len(v)\nreturn nil\nfunction main()\nexercise()\n? "done"\nreturn nil\nfunction fresh()\nlocal d\nd := "owned"\nreturn d\n';src.write_text(s)
    try:r=emit_delta(compiler,env,src,w,b'\n         7\ndone')
    except Exception as e:r=dict(state_ok=False,delta=None,error=str(e))
    vals['control' if control else 'actual']=r
   add('data-store-'+name+'-'+str(n),'data-store-memory-control',all(v['state_ok'] and v['delta']==3 for v in vals.values()),bound=3,states=vals)
ident=dict(compiler_tree=a.tree,compiler_sha256=hashlib.sha256(P(compiler).read_bytes()).hexdigest(),scope='Linux runtime, external Harbour3.2 oracle, Wine if supplied; Mac emission is separate',total=len(rows),passed=sum(x['pass_'] for x in rows),rows=rows);(out/'results.json').write_text(json.dumps(ident,indent=2));sys.exit(0 if ident['total']==ident['passed'] else 1)
