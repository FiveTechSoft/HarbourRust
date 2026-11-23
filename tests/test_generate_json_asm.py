#!/usr/bin/env python3
"""Check note filtering, recipe byte hashes, and checkout EOL attributes."""
import hashlib
import json
from pathlib import Path
import subprocess
import unittest
from json_asm_sections import strip_empty_gnu_stack

root = Path(__file__).resolve().parents[1]
marker = '\t.section\t.note.GNU-stack,"",@progbits\n'


class NoteSections(unittest.TestCase):
    def test_empty_final_marker(self):
        self.assertEqual(strip_empty_gnu_stack('.text\nret\n' + marker), '.text\nret\n')

    def test_empty_then_text(self):
        self.assertEqual(strip_empty_gnu_stack(marker + '# marker only\n\n.text\nret\n'), '.text\nret\n')

    def test_reject_unknown_note(self):
        for name in ['.note.gnu.property', '.note', '.noteXYZ', '".note.GNU-stack"']:
            with self.subTest(name=name), self.assertRaises(ValueError):
                strip_empty_gnu_stack('.section ' + name + ',"",@progbits\n')

    def test_reject_nonempty_stack(self):
        for body in ['.byte 1\n', 'label:\n', '.zero 4\n', '.balign 8\n', 'ret\n']:
            with self.subTest(body=body), self.assertRaises(ValueError):
                strip_empty_gnu_stack(marker + body)

    def test_reject_flags_or_alternate_type(self):
        for line in ['.section .note.GNU-stack,"x",@progbits\n',
                     '.section .note.GNU-stack,"",@note\n',
                     '.section .note.GNU-stack,"",@progbits; .byte 1\n']:
            with self.subTest(line=line), self.assertRaises(ValueError):
                strip_empty_gnu_stack(line)

    def test_reject_section_stack(self):
        for line in ['.pushsection .text\n', '.popsection\n', '.previous\n']:
            with self.subTest(line=line), self.assertRaises(ValueError):
                strip_empty_gnu_stack(marker + line)


class RecipeBytes(unittest.TestCase):
    def test_hashes_match_lf_bytes(self):
        recipe = json.loads((root / 'generated/hrjson_recipe.json').read_bytes())
        for file, key in [('runtime/hrjson.c', 'source_sha256'), ('generated/hrjson.s', 'asm_sha256')]:
            data = (root / file).read_bytes()
            self.assertNotIn(b'\r', data)
            self.assertEqual(hashlib.sha256(data).hexdigest(), recipe[key])
        self.assertIn('LF bytes', recipe['newline_policy'])

    def test_attributes_force_lf(self):
        result = subprocess.check_output(['git', 'check-attr', 'text', 'eol', '--',
                                          'runtime/hrjson.c', 'generated/hrjson.s'], cwd=root, text=True)
        self.assertEqual(result.splitlines(), [
            'runtime/hrjson.c: text: set', 'runtime/hrjson.c: eol: lf',
            'generated/hrjson.s: text: set', 'generated/hrjson.s: eol: lf'])

    def test_no_note_survives(self):
        self.assertNotIn('.note', (root / 'generated/hrjson.s').read_text())


if __name__ == '__main__':
    unittest.main()
