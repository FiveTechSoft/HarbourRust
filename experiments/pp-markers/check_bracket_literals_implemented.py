#!/usr/bin/env python3
"""Source literal checks keep reader/macro provenance distinct from templates."""
import pathlib,subprocess,json,argparse
p=argparse.ArgumentParser();p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True)
cases=[('? [a;b]','? [a;b]'),('? [a//b]','? [a//b]'),('? [a&&b]','? [a&&b]'),('? [a\'"b]','? [a\'"b]'),('#define X 7\n? [X]','? [X]'),('#define X 7\n? a [X]','? a [7]'),('#define X 7\n#define BODY ? [X]\nBODY','? [7]'),('#define F(x) [x]\n? F(7)','? [7]'),('#define F(x) ? [x]\nF(7)','? [7]'),('#define ID(x) x\n? ID([a,b])','? "a,b"'),('#define ID(x) x\n? ID([a\'b])','? "a\'b"'),('#xtranslate ID(<x>) => <x>\n? ID([a(,);b])','? [a(,);b]'),('#translate WORD TOKEN => 7\n? [WORD TOKEN], WORD TOKEN','? [WORD TOKEN], 7')]
rows=[]
for n,(source,expected) in enumerate(cases):
 f=out/f'case{n}.prg';f.write_text(source+'\n');p=subprocess.run([a.hpp,str(f)],capture_output=True,text=True);assert p.returncode==0 and p.stdout.strip()==expected,(source,p.stdout,p.stderr,expected);rows.append({'case':n,'source':source,'output':p.stdout,'verified':True})
(out/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print('13bracket phase/output checks PASS;runtime reference checked separately')
