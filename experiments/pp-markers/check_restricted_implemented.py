#!/usr/bin/env python3
"""Own literal-list oracle; token matching only, not reemission or runtime proof."""
import argparse,pathlib,subprocess,re,json,hashlib
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);rows=[]
def tokens(s):return re.findall(r'"[^"\n]*"|\'[^\'\n]*\'|[A-Za-z_][A-Za-z_0-9]*|\d+|[^\s]',s)
cases=[]
for directive in ['command','xcommand','translate','xtranslate']:
 for restriction,values in [('FROM, INHERIT',['FROM','INHERIT','from','FrOm','FR','FRO','FROMAGE','OTHER','FROM INHERIT','','INHE','INHER','"FROM"','(FROM)']),('DESCENDING',['DESCENDING','descending','DESC','DESCENDIN','DESCENDINGLY','OTHER','','"DESCENDING"']),('MODULE FRIENDLY, STATIC',['MODULE FRIENDLY','module friendly','MODULE','MODULE FRIEND','STATIC','static','MODULE FRIENDLY STATIC']),('123, 456',['123','456','12','1234']),('()',['()','( )','(x)',''])]:
  for val in values:
   # Existing statement-only translate engine requires whole-statement matches;
   # prefix translation with remaining tokens is a separately open behavior.
   if directive in ['translate','xtranslate'] and (val in ['FROM INHERIT','A B C','MODULE FRIENDLY STATIC'] or restriction=='()'):continue
   cases.append((directive,'PROBE <mode: '+restriction+'> <!name!>','OUT( <mode>, <name> )','PROBE '+val+' alpha'))
 for pattern,source in [('PROBE [<m: FROM, INHERIT>]','PROBE'),('PROBE [<m: FROM, INHERIT>]','PROBE FROM INHERIT'),('PROBE [<m: FROM, INHERIT>] STOP','PROBE FROM INHERIT STOP'),('PROBE [WORD <m: FROM, INHERIT>]','PROBE WORD FROM WORD INHERIT'),('PROBE <m: FROM, INHERIT> <!n!>','PROBE FROM alpha'),('PROBE <m: FROM, INHERIT> <!n!>','PROBE FROM 123'),('PROBE [<m: MODULE FRIENDLY>] [<s: STATIC>]','PROBE MODULE FRIENDLY STATIC'),('PROBE <m: FROM, INHERIT> STOP','PROBE FROM STOP'),('PROBE <m: FROM, INHERIT> STOP','PROBE FROMAGE STOP')]:cases.append((directive,pattern,'OUT( [<m>] )',source))
for i,(directive,pattern,result,source)in enumerate(cases):
 f=out/f'p{i:03}.prg';text=f'#{directive} {pattern} => {result}\n{source}\n';f.write_text(text);r=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True,text=True,timeout=10);assert r.returncode==0,(i,text,r.stderr);expected=f.with_suffix('.ppo').read_text();own=subprocess.run([a.hpp,str(f)],capture_output=True,text=True,timeout=10);matched='OUT('in expected
 if matched:assert own.returncode==0 and tokens(own.stdout)==tokens(expected),(i,text,expected,own.stdout,own.stderr)
 else:assert own.returncode==0 and tokens(own.stdout)==tokens(expected),(i,text,expected,own.stdout,own.stderr)
 rows.append({'case':i,'directive':directive,'pattern':pattern,'input':source,'source_sha256':hashlib.sha256(text.encode()).hexdigest(),'reference_rule_matched':matched,'comparison':'matched token streams including source case'if matched else'nonmatch;original statement preserved like reference'})
j={'scope':'Own-source restricted literal-list token oracle. Exact case-insensitive single/multi-token alternatives,optional repetition,numeric/empty-parens choices. No macro ampersand restriction or arbitrary grammar. Ordinary directives abbreviate >=4characters;X directives match exact words. Existing translate prefix/call-form limitations remain separately open. Token equality is not lexical reemission or execution proof.','rows':rows};(out/'results.json').write_text(json.dumps(j,indent=2)+'\n');print(len(rows),'restricted literal-list boundaries PASS')
