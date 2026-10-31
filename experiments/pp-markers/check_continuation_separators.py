#!/usr/bin/env python3
"""Own continuation-reader probes,not complete grammar coverage."""
import pathlib,argparse,json,re,subprocess,tempfile
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);a=p.parse_args();root=pathlib.Path(__file__).parent/'continuation-separators-20261031'
def tok(s):return [x for x in re.findall(r'"[^"\n]*"|\x27[^\x27\n]*\x27|[A-Za-z_][A-Za-z_0-9]*|\d+|[^\s]',s)if x!=';']
with tempfile.TemporaryDirectory(prefix='continuation-replay-')as d:
 f=pathlib.Path(d)/'probe.prg'
 for r in json.loads((root/'matrix72.json').read_text())['rows']:
  f.write_text(r['source']);h=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True,text=True,timeout=10);o=subprocess.run([a.hpp,str(f)],capture_output=True,text=True,timeout=10);ref=f.with_suffix('.ppo').read_text();assert h.returncode==o.returncode==0 and tok(ref)==tok(r['reference_output'])==tok(o.stdout),(r['source'],ref,o.stdout,o.stderr)
print('72continuation boundary checks PASS;statement separators normalized,quoted semicolons literal')
