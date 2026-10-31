#!/usr/bin/env python3
"""Rebuild own-source observation inputs and verify pinned hbpp evidence."""
import argparse,pathlib,subprocess,json
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--evidence',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();d=json.loads(pathlib.Path(a.evidence).read_text());rows=d['rows']if isinstance(d,dict)else d;out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True)
for i,r in enumerate(rows):
 f=out/f'case{i}.prg';f.write_text(r['source']);o=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True,text=True,timeout=10);text=f.with_suffix('.ppo').read_text()if f.with_suffix('.ppo').exists()else''
 assert o.returncode==r['reference_exit']and text==r['reference_output'],(i,r['source'],r['reference_output'],text,o.stderr)
print(len(rows),'reference observations reproduced exactly;not compiler support')
