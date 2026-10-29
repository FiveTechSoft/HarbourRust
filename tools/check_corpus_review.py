#!/usr/bin/env python3
"""Validate manual metadata provenance. Never compile, execute or infer readiness."""
import argparse,pathlib,json,hashlib,collections
p=argparse.ArgumentParser();p.add_argument('--core',required=True);p.add_argument('--output',required=True);a=p.parse_args();repo=pathlib.Path(__file__).resolve().parents[1];corpus=repo/'corpus';core=pathlib.Path(a.core).resolve();review=json.loads((corpus/'manual-entrypoint-dependencies-20261029.json').read_text());inv=json.loads((corpus/'harbour-694428e1-inventory.json').read_text());inventory={r['path']:r for r in inv['files']};assert review['reference']==inv['reference'];families=collections.defaultdict(list)
for row in review['files']:
 path=row['file'];assert path in inventory;data=(core/path).read_bytes();assert hashlib.sha256(data).hexdigest()==row['sha256']==inventory[path]['sha256'],path
 lines=data.decode('utf-8').splitlines()
 for w in row['witnesses']:
  actual=[i+1 for i,line in enumerate(lines) if w['symbol_or_construct'].lower() in line.lower()];assert actual==w['lines'],(path,w)
 for family in row['families']:families[family].append(path)
for project in review['build_projects']:
 assert hashlib.sha256((core/project['file']).read_bytes()).hexdigest()==project['sha256']
 for member in project['members']:assert member in inventory and member in [r['file'] for r in review['files']]
for group in review.get('source_groupings',[]):
 assert len(group['members'])>=2
 for member in group['members']:assert member in inventory and member in [r['file']for r in review['files']]
result={'reference':review['reference'],'scope':'Manual review provenance and source-family index only. Not parser-recognized syntax or supported feature counts. Dependencies are not installed-availability claims. No compilation/execution. Does not replace17family seed or268audit.','reviewed_sources':len(review['files']),'build_projects':len(review['build_projects']),'family_index':[{'family':k,'reviewed_sources':v,'implementation_status':'not-inferred-from-source-review','next_gate':'see individual review records; representation/effect authority remains separate'}for k,v in sorted(families.items())]};pathlib.Path(a.output).write_text(json.dumps(result,indent=2)+'\n');print(f"PASS {len(review['files'])} reviewed source hashes/witnesses and {len(review['build_projects'])} project;{len(families)} observed family tags,not coverage")
