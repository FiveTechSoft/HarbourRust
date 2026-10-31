#!/usr/bin/env python3
"""Replay own reduced-VAR corpus. Rejections and unmatched gaps are not support."""
import argparse,pathlib,json,gzip,subprocess,re,collections
p=argparse.ArgumentParser();p.add_argument('--statement-separators',action='store_true');p.add_argument('--corpus',default='reduced-var-20261031/cases.json.gz');p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();root=pathlib.Path(__file__).resolve().parent;out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True)
tok=lambda s:re.findall(r'"[^"\n]*"|\x27[^\x27\n]*\x27|[^\s]',s);
if a.statement_separators:
 original_tok=tok
 tok=lambda s:[t for t in original_tok(s)if t!=';']
counts=collections.Counter();rows=[]
for i,row in enumerate(json.loads(gzip.decompress((root/a.corpus).read_bytes()))):
 f=out/'replay.prg';f.write_text(row['source']);h=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True,text=True,timeout=10);ref=f.with_suffix('.ppo').read_text();o=subprocess.run([a.hpp,str(f)],capture_output=True,text=True,timeout=10)
 assert h.returncode==0 and tok(ref)==tok(row['reference_output']),(i,'reference drift',ref)
 same=o.returncode==0 and tok(o.stdout)==tok(ref)
 if o.returncode!=0:
  assert 'outside bounded contract' in o.stderr or 'multiple repeated result owners' in o.stderr,(i,o.stderr)
  category='explicit_rejection_not_support'
 elif same:category='token_match'
 else:
  assert 'OUT(' not in re.sub(r'\s','',o.stdout),(i,'false translation',row['source'],ref,o.stdout)
  category='unmatched_known_gap'
 assert category==row['category'],(i,'category drift',row['category'],category,row['source'])
 counts[category]+=1;rows.append({'index':i,'category':category})
summary={'scope':'deduplicated own reduced VAR probes; token equality is not runtime or original coverage; rejection/unmatched counts are gaps','counts':dict(counts),'total':len(rows),'false_translations':0};(out/'summary.json').write_text(json.dumps(summary,indent=2)+'\n');print(json.dumps(summary))
