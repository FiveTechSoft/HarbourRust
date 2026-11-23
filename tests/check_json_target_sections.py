#!/usr/bin/env python3
"""Check target-specific JSON sections in real compiler assembly output."""
import argparse
from pathlib import Path
import re
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser()
p.add_argument('--compiler', required=True)
a = p.parse_args()
hbc = str(Path(a.compiler).resolve())
blob = (root / 'generated/hrjson.s').read_text()
assert blob.count('@HRJSON_RODATA@') == 5
# All bytes except the five section directives must be preserved.
with tempfile.TemporaryDirectory() as temp:
    for target in ('linux', 'windows'):
        for instrument in (False, True):
            asm = Path(temp) / 'json.s'
            flags = ['--instrument'] if instrument else []
            subprocess.run([hbc, 'tests/json-safety/programs/strings.prg', str(asm),
                            '--target=' + target] + flags,
                           cwd=root, capture_output=True, check=True, timeout=30)
            text = asm.read_text()
            expected = '.section .rodata' if target == 'linux' else '.section .rdata,"r"'
            expanded = blob.replace('@HRJSON_RODATA@', expected)
            # The final emitter removes leading comments/directives; compare
            # the complete blob from its first label through its final .text.
            first_label = re.search(r'^[A-Za-z_][A-Za-z0-9_.$]*:', expanded, re.M).group(0)
            expanded = expanded[expanded.index(first_label):]
            assert expanded in text, (target, instrument, 'JSON blob not preserved')
            assert '@HRJSON_RODATA@' not in text
            assert '.section .rdata' not in expanded if target == 'linux' else '.section .rodata' not in expanded
            assert len(re.findall(r'^\.section ', expanded, re.M)) == 5
            print('PASS JSON sections', target, 'instrument=' + str(instrument))
