#!/usr/bin/env python3
"""Replay bounded alias observations, distinguishing known matrix gaps."""
import argparse,json,pathlib,re,subprocess,tempfile
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);a=p.parse_args();root=pathlib.Path(__file__).parent/'identifier-alias-20261031'
def rawtok(s):return re.findall(r'"[^"\n]*"|\x27[^\x27\n]*\x27|[A-Za-z_][A-Za-z_0-9]*|\d+|[^\s]',s)
def tok(s):return [t for t in rawtok(s) if t != ';']  # statement separators only;quoted semicolons remain literal

with tempfile.TemporaryDirectory(prefix='alias-replay-')as d:
 f=pathlib.Path(d)/'probe.prg';count=0;gaps=0
 for name in ['probes7.json','controls6.json','matrix240.json']:
  for r in json.loads((root/name).read_text())['rows']:
   f.write_text(r['source']);h=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True,text=True,timeout=10);o=subprocess.run([a.hpp,str(f)],capture_output=True,text=True,timeout=10);ref=f.with_suffix('.ppo').read_text()
   assert h.returncode==r['reference_exit'] and tok(ref)==tok(r['reference_output']),('reference drift',r['source'])
   assert o.returncode==r['own_exit'] and tok(o.stdout)==tok(r['own_output']),('implementation drift',r['source'],o.stdout,o.stderr)
   if r.get('match',True):
    assert (h.returncode!=0 and o.returncode!=0)or(h.returncode==o.returncode==0 and tok(ref)==tok(o.stdout)),r['source'];count+=1
   else:gaps+=1
print(count,'bounded alias token/recursion checks PASS;',gaps,'preserved preexisting matrix gaps,not support')
