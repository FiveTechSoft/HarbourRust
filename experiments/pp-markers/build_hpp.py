#!/usr/bin/env python3
"""Adapt stale debug frontend constructor in a temp file, Linux profile only."""
import argparse,pathlib,tempfile,subprocess
p=argparse.ArgumentParser();p.add_argument('--output',required=True);a=p.parse_args();root=pathlib.Path(__file__).resolve().parents[2];s=(root/'src/hpp.rs').read_text();assert 'pp::Pp::new(incdirs);' in s;s=s.replace('pp::Pp::new(incdirs);','pp::Pp::new(incdirs, false);').replace('#[path = "pp.rs"]',f'#[path = "{root}/src/pp.rs"]')
with tempfile.TemporaryDirectory(prefix='hpp-marker-')as d:
 f=pathlib.Path(d)/'hpp.rs';f.write_text(s);subprocess.run(['rustc','--edition=2021','-O',str(f),'-o',a.output],check=True)
