#!/usr/bin/env python3
"""Validate and join a planning crosswalk; no program execution or compiler call."""
import pathlib,json,argparse,collections
p=argparse.ArgumentParser();p.add_argument('--output',required=True);a=p.parse_args();root=pathlib.Path(__file__).resolve().parents[1]/'corpus';tax=json.loads((root/'syntax-workstream-taxonomy.json').read_text());manual=json.loads((root/'manual-entrypoint-dependencies-20261029.json').read_text());index=json.loads((root/'manual-review-family-index.json').read_text());seed=json.loads((root/'syntax-family-seed-b105ae0.json').read_text());tags={x['family']for x in index['family_index']};seen=[];seeds=[];rows=[]
for w in tax['workstreams']:
 seen+=w['observed_manual_tags'];seeds+=w['seed_family_ids'];sources=[r['file']for r in manual['files']if set(r['families'])&set(w['observed_manual_tags'])];cases=sorted({c['file']for f in seed['families']if f['id']in w['seed_family_ids']for c in f['cases']});rows.append({'workstream':w['id'],'phase':w['roadmap_phase'],'manual_source_paths':sources,'seed_regression_paths':cases,'seed_case_count':len(cases),'missing_seed_link':not bool(w['seed_family_ids']),'status':'routing-evidence-only;not-complete-or-supported'})
assert len(seen)==len(set(seen))and set(seen)==tags
assert len(seeds)==len(set(seeds))and set(seeds)=={f['id']for f in seed['families']}
assert len(manual['files'])==tax['current_manual_review_sources'];assert len(seed['families'])==tax['current_seed_families']
result={'meaning':'Planning evidence crosswalk,not coverage. Sources may appear in multiple workstreams; never sum memberships as distinct programs. No new compile/run/check result. Seed provenance remains b105ae0 compile-only.','workstreams':rows};pathlib.Path(a.output).write_text(json.dumps(result,indent=2)+'\n');print(f'PASS {len(rows)} planning workstreams;{len(seen)} manual tags assigned once;{len(seeds)} seed families linked,not completed')
