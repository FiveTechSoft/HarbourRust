#!/usr/bin/env python3
"""Reject terminal adapters that finalize_trace would redirect to legacy panic."""
from pathlib import Path
import argparse,re
p=argparse.ArgumentParser();p.add_argument('--source',type=Path);p.add_argument('--assembly-dir',type=Path,default=Path(__file__).parent);a=p.parse_args()
patterns=['    mov $60, %eax\n    mov $1, %edi\n    syscall','    mov $1, %ecx\n    call ExitProcess']
if a.source:
 s=a.source.read_text();blocks=[]
 for platform in ['LINUX','WINDOWS']:
  m=re.search(r'const MACRO_FAIL_'+platform+r': &str = r#?"(.*?)"#?;',s,re.S)
  if not m:raise SystemExit('FAIL: missing MACRO_FAIL_'+platform)
  blocks.append((platform,m.group(1)))
else:blocks=[(platform,(a.assembly_dir/('terminal-'+platform+'.s')).read_text()) for platform in ['linux','windows']]
for name,s in blocks:
 for pattern in patterns:
  if pattern in s:raise SystemExit('FAIL: '+name+' contains a legacy-exit-rewrite pattern')
print('PASS: both terminal exits avoid finalize_trace legacy panic rewrite')
