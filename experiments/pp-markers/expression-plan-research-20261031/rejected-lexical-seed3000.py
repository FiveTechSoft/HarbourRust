import pathlib,subprocess,json,re,random
b=pathlib.Path('/downloads/helper-study/expressionlexical');b.mkdir(exist_ok=True);rows=[];rng=random.Random(4197)
args=['a[1]','a[1,2]','a[1][2]','f()[1]','(a)[1]','a[1+AS]','a[]','1[2]','a[1]b','a .AND. b','a:b()','a->b','{1,2}','.T.','1.2','a**2','a := 2','&x.','a +','a + AS','a + AS DECL','d"2026-01-01"','0d20261031','0xFE','1e2','a++','++a','a++b','a-- DECL','&x. DECL','&(x)','a .OR. DECL','.NOT. AS','@f()','{|| AS}','a:AS','a->AS','a[AS,DECL]','New Other','1 2','()','-','[word]','e"a\\nb"','a\\b']
for i in range(3000):
 flags=rng.sample(['AS','CLASS','DECL','INLINE'],rng.randrange(1,5));pat=' '.join('['+f+(' <'+f.lower()+'>'if f!='DECL'else'')+']'for f in flags);tail=[]
 for j in range(rng.randrange(4)):
  f=rng.choice(flags);tail+=[f]
  if f!='DECL':tail+=[rng.choice(args)]
 result='OUT(<name>'+''.join((' [,<'if rng.choice([True,False])else',<')+f.lower()+('>]'if False else '>')for f in [])+')'
 result=rng.choice(['OUT(<name>'+''.join(' [,<'+f.lower()+'>]'for f in flags if f!='DECL')+')','OUT(<name>'+''.join(',<'+f.lower()+'>'for f in flags if f!='DECL')+')'])
 s='#xcommand METHOD <name> '+pat+' => '+result+'\nMETHOD '+rng.choice(args)+' '+ ' '.join(tail)+'\n';p=b/'probe.prg';p.write_text(s);h=subprocess.run(['/tmp/harbour-reference/bin/linux/gcc/hbpp',str(p),'-q2'],capture_output=True,text=True);o=subprocess.run(['/downloads/expression-plan-hpp',str(p)],capture_output=True,text=True);ref=p.with_suffix('.ppo').read_text();tok=lambda s:re.findall(r'"[^"\n]*"|\x27[^\x27\n]*\x27|\w+|[^\s]',s);rows.append(dict(source=s,refexit=h.returncode,ref=ref,exit=o.returncode,own=o.stdout,error=o.stderr,match=h.returncode==o.returncode==0 and tok(ref)==tok(o.stdout)))
(b/'results.json').write_text(json.dumps(rows,indent=2));print('lexical',sum(r['match']for r in rows),'/',len(rows));print([r for r in rows if not r['match']][:8])
