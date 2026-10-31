from pathlib import Path
import subprocess,json,hashlib
w=Path('/downloads/verify-aeval573d572');b=Path('/downloads/verify-aeval-contracts');hb='/tmp/harbour-reference/bin/linux/gcc/hbmk2'
def run(cmd):
 try:
  q=subprocess.run(list(map(str,cmd)),capture_output=True,timeout=10,cwd=b);return dict(exit=q.returncode,stdout=q.stdout.decode(errors='replace'),stderr=q.stderr.decode(errors='replace'))
 except subprocess.TimeoutExpired as e:return dict(exit=None,timeout=10,stdout=(e.stdout or b'').decode(errors='replace'),stderr=(e.stderr or b'').decode(errors='replace'))
cases={'original':Path('/tmp/harbour-reference/tests/arreval.prg').read_text(),'start_effects':(b/'start-effects.prg').read_text(),
'count_on_negstart':'''function main()
local a := {10,20,30}
AEval(a,{|x,i| QOut(x,i)},mark(-1),mark(2))
return nil
function mark(n)
? n
return n+0
''',
'overflow_count':'''function main()
local a := {10,20,30}
AEval(a,{|x,i| QOut(x,i)},2,9223372036854775807)
return nil
''',
'overflow_start':'''function main()
local a := {10,20,30}
AEval(a,{|x,i| QOut(x,i)},9223372036854775807,2)
return nil
''',
'callback_returns':'''function main()
local a := {10,20,30}
AEval(a,{|x,i| x+i})
AEval(a,{|x,i| x:=99})
AEval(a,{|x,i| QOut(x,i)})
return nil
''',
'empty':'''function main()
local a := {}
AEval(a,{|x,i| QOut(x,i)})
return nil
''',
'capturing_mutation':'''function main()
local a := {10,20,30}
AEval(a,{|x,i| a[i]:=x+1})
AEval(a,{|x,i| QOut(x,i)})
return nil
''',
'block_one_param':'''function main()
local a := {10,20,30}
AEval(a,{|x| QOut(x)})
return nil
''',
'block_zero_param':'''function main()
local a := {10,20,30}
AEval(a,{|| QOut("X")})
return nil
''',
'neg_bounds':'''function main()
local a := {10,20,30}
AEval(a,{|x,i| QOut(x,i)},0,-1)
AEval(a,{|x,i| QOut(x,i)},-1,2)
AEval(a,{|x,i| QOut(x,i)},1,0)
return nil
'''}
cases.update({
'callback_intret':'function main()\nlocal a := {10,20,30}\nAEval(a,{|x,i| x+i})\nAEval(a,{|x,i| QOut(x,i)})\nreturn nil\n',
'callback_paramassign':'function main()\nlocal a := {10,20,30}\nAEval(a,{|x,i| (x:=99)})\nAEval(a,{|x,i| QOut(x,i)})\nreturn nil\n',
'capture_parenthesized':'function main()\nlocal a := {10,20,30}\nAEval(a,{|x,i| (a[i]:=x+1)})\nAEval(a,{|x,i| QOut(x,i)})\nreturn nil\n',
'empty_pinned':'function main()\nlocal a := {10}\nASize(a,0)\nAEval(a,{|x,i| QOut(x,i)})\nreturn nil\n',
'generated_collision':'function main()\nlocal a := {10,20,30}\nlocal __aeval_s_4 := 99\nAEval(a,{|x,i| QOut(x,i)})\n? __aeval_s_4\nreturn nil\n'
})
for n in [1412,1413]:p=next((w/'tests').glob('t'+str(n)+'*'));cases[p.stem]=p.read_text()
rows=[]
for n,src in cases.items():
 p=b/(n+'.prg');p.write_text(src);ref=b/(n+'-ref');r=dict(name=n,source=src,source_sha256=hashlib.sha256(p.read_bytes()).hexdigest());r['ref_build']=run([hb,p,'-q','-gtstd','-o'+str(ref)])
 if r['ref_build']['exit']==0:r['reference']=run([ref])
 r['compile']=run([w/'hbc',p,b/(n+'.s')])
 if r['compile']['exit']==0:
  r['assemble']=run(['as','-o',b/(n+'.o'),b/(n+'.s')]);r['link']=run(['ld','-o',b/n,b/(n+'.o')])
  if r['link']['exit']==0:r['execution']=run([b/n]);r['exact']=r['execution']==r.get('reference')
 rows.append(r);print(n,r.get('exact'),r['compile']if r['compile']['exit']else r.get('execution'),flush=True);(b/'results.json').write_text(json.dumps(rows,indent=2)+'\n')
