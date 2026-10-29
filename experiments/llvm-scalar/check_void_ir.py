"""Assert the bounded internal ABI, not a tagged NIL or dummy integer result."""
import pathlib,re
p=pathlib.Path('run')
for stem,names in [('corpus',['voideffect','voidlogical']),('voideffects',['leaf','recurse','early','ping','pong']),('returns-original',['two']),('ifelse-original',['testvalue']),('statfun-original',['secondone'])]:
 for suffix in ['.ll']+(['_w.ll'] if (p/(stem+'_w.ll')).exists() else []):
  text=(p/(stem+suffix)).read_text()
  for name in names:
   assert f'define void @ll_{name}(' in text,(stem,name)
   assert not re.search(r'(?:define|call) i64 @ll_'+name+r'\(',text),(stem,name)
   body=text.split(f'define void @ll_{name}(',1)[1].split('\n}',1)[0]
   assert 'ret void' in body and 'ret i64' not in body,(stem,name)
   # Every normal return must unlink the trace frame before returning.
   for part in body.split('ret void')[:-1]:
    assert re.search(r'store volatile ptr %v\d+, ptr @hbc_trace_top\s*$',part),(stem,name)
print('PASS internal void/call-void ABI shape and trace unlink at every return')
