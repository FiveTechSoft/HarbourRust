#!/usr/bin/env python3
"""Join separate evidence gates without promoting compile acceptance to execution."""
import argparse,json,pathlib,collections
p=argparse.ArgumentParser();p.add_argument('--output',required=True);a=p.parse_args();root=pathlib.Path(__file__).resolve().parents[1]/'corpus';inv=json.loads((root/'harbour-694428e1-inventory.json').read_text());rows={r['path']:{'path':r['path'],'sha256':r['sha256'],'kind':r['kind'],'profile':r['profile'],'compile':{},'execution':{},'review':{'entrypoint':'not-reconciled','dependencies':'not-reconciled'}}for r in inv['files']}
def check(row):
 r=rows[row['file']];assert r['sha256']==row['sha256'],row['file'];return r
frozen=json.loads((root/'frozen175-f5daec7-compile.json').read_text());wide=json.loads((root/'tests268-9e9ff8b-compile.json').read_text())
for x in wide['rows']:
 r=check(x)
 for key,profile in [('current','linux-default'),('llvm','linux-llvm'),('current_windows','windows-default'),('llvm_windows','windows-llvm')]:r['compile'][profile]={'accepted':x[key]['compiled'],'compiler':wide['compiler'],'evidence':'tests268-9e9ff8b-compile.json'}
for filename in ['console14-89f3ead-execution.json','default5-cda9176-execution.json']:
 d=json.loads((root/filename).read_text())
 for x in d['rows']:
  r=check(x);assert x['exact'];r['review']={'entrypoint':'reviewed-linux-console','dependencies':'reviewed-console-only','limits':'other targets not reviewed; no automatic bulk execution'}
  for backend in x['outputs']:r['execution']['linux-'+backend]={'exact_with_reference':True,'compiler':d['compiler'],'evidence':filename,'exit':x['outputs'][backend]['exit'],'stdout_bytes':x['outputs'][backend]['stdout_bytes']}
manual=json.loads((root/'manual-entrypoint-dependencies-20261029.json').read_text())
assert len(manual['files']) == len({r['file'] for r in manual['files']}), 'duplicate manual review source'
for x in manual['files']:
 r=check(x);r['manual_review']={'evidence':'manual-entrypoint-dependencies-20261029.json','entrypoint':x['entrypoint'],'build_unit':x['build_unit'],'families':x['families'],'next_gate':x['next_gate'],'execution_permission':x['execution_permission']}
 # Retain reviewed-console execution provenance on the five overlaps.
 if not r['execution']:r['review']={'entrypoint':'manually-reviewed-profile-specific','dependencies':'requirements-and-harness-risks-reviewed','limits':'metadata review only; no execution readiness or permission inferred'}
result={'reference':inv['reference'],'meaning':'Reconciled evidence, not a language coverage percentage. No new programs executed. Missing gates remain unknown. Linux platform-empty dynwin acceptance is not DLL support.','counts':{'inventory_files':len(rows),'original_test_sources_compile_audited':len(wide['rows']),'manual_entrypoint_dependency_reviews':len(manual['files']),'manually_reviewed_or_executed_sources':sum(bool(r.get('manual_review'))or bool(r['execution'])for r in rows.values()),'frozen175_default_accepted':sum(x['current']['compiled']for x in frozen['rows']),'frozen175_llvm_accepted':sum(x['llvm']['compiled']for x in frozen['rows']),'execution_exact_by_profile':dict(collections.Counter(k for r in rows.values()for k in r['execution']))},'files':list(rows.values())};pathlib.Path(a.output).write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result['counts'],sort_keys=True))
