from pathlib import Path
import subprocess,json,random,re
b=Path('/downloads/helper-study/restrictedseed');b.mkdir(exist_ok=True);rs=[];rng=random.Random(4511)
clauses=['[<scope:PUBLIC,VISIBLE>]','[AS <t>]','[<hidden:HIDDEN>]','[DECL]','[<sync:SYNC>]','[<ctor:CONSTRUCTOR>]','[<persist:PERSISTENT,PROPERTY>]','[<guard:GUARDED>]']
for _ in range(3000):
 chosen=rng.sample(clauses,rng.randrange(1,9));names=[re.search(r'<(\w+)',c).group(1)for c in chosen if '<'in c];tail=[]
 for i in range(rng.randrange(7)):
  c=rng.choice(chosen)
  if c=='[AS <t>]':tail+=['AS',rng.choice(['T','f(1,2)','T+PUBLIC','DECL','GUARDED'])]
  else:tail+=[rng.choice(re.search(r':([^>]+)',c).group(1).split(','))if':'in c else'DECL']
 result='OUT(<x>'+''.join((' [,<"'+n+'">]'if rng.choice([True,False])else',<"'+n+'">')for n in names)+')'
 s='#command SHOW <x> '+' '.join(chosen)+' => '+result+'\nSHOW New() '+' '.join(tail)+'\n';p=b/'probe.prg';p.write_text(s);h=subprocess.run(['/tmp/harbour-reference/bin/linux/gcc/hbpp',str(p),'-q2'],capture_output=True,text=True);o=subprocess.run(['/downloads/restricted-root-hpp',str(p)],capture_output=True,text=True);ref=p.with_suffix('.ppo').read_text();tok=lambda s:re.findall(r'"[^"\n]*"|\w+|[^\s]',s);rs.append(dict(source=s,refexit=h.returncode,ref=ref,exit=o.returncode,own=o.stdout,error=o.stderr,match=h.returncode==o.returncode==0 and tok(ref)==tok(o.stdout)))
(b/'results3000.json').write_text(json.dumps(rs,indent=2));print('RESTRICTED3000',sum(r['match']for r in rs));print([r for r in rs if not r['match']][:6])
