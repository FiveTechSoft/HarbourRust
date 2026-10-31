import pathlib,subprocess,json,itertools,re,random
b=pathlib.Path('/downloads/helper-study/expressionseed');b.mkdir(exist_ok=True);rows=[]
def tok(s):return re.findall(r'"[^"\n]*"|\x27[^\x27\n]*\x27|\w+|[^\s]',s)
sources=[r['source']for r in json.load(open('/downloads/helper-study/methodrepeat/observations26.json'))['rows']]
rng=random.Random(3817)
for i in range(1800):
 flags=rng.sample(['AS','CLASS','DECL','INLINE'],rng.randrange(1,5));pat=' '.join('['+f+(' <'+f.lower()+'>'if f!='DECL'else'')+']'for f in flags);args=['New','New()','(New)','7','"AS"','f(1,2)','a+DECL','a*CLASS','-a','DECL','AS','f(AS,DECL)'];tail=[]
 for j in range(rng.randrange(5)):
  f=rng.choice(flags);tail+=[f]
  if f!='DECL':tail+=[rng.choice(args)]
 result=rng.choice(['OUT(<name>'+''.join(' [,<'+f.lower()+'>]'for f in flags if f!='DECL')+')','OUT(<name>'+''.join(',<'+f.lower()+'>'for f in flags if f!='DECL')+')'])
 sources.append('#xcommand METHOD <name> '+pat+' => '+result+'\nMETHOD '+rng.choice(args)+' '+ ' '.join(tail)+'\n')
for s in sources:
 p=b/'probe.prg';p.write_text(s);h=subprocess.run(['/tmp/harbour-reference/bin/linux/gcc/hbpp',str(p),'-q2'],capture_output=True,text=True);o=subprocess.run(['/downloads/expression-plan-hpp',str(p)],capture_output=True,text=True);ref=p.with_suffix('.ppo').read_text();rows.append(dict(source=s,reference_exit=h.returncode,reference_output=ref,own_exit=o.returncode,own_output=o.stdout,own_error=o.stderr,match=h.returncode==o.returncode==0 and tok(ref)==tok(o.stdout)))
print('TOTAL',len(rows),'MATCH',sum(r['match']for r in rows),'BAD', [r for r in rows if not r['match']][:8]);(b/'results.json').write_text(json.dumps({'rows':rows},indent=2)+'\n')
