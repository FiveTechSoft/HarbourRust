"""Reject assembly note payloads; omit only an empty GNU-stack marker."""
import re


def strip_empty_gnu_stack(assembly):
    result = []
    in_note = False
    marker = re.compile(r'^\s*\.section\s+\.note\.GNU-stack\s*,\s*""\s*,\s*@progbits\s*(?:#.*)?$')
    switch = re.compile(r'^\s*\.(?:section|pushsection|popsection|previous|text|data|bss)\b')
    for line in assembly.splitlines(keepends=True):
        if re.match(r'^\s*\.(?:pushsection|popsection|previous)\b', line):
            raise ValueError('Section stack switches are not supported in JSON assembly')
        note = re.match(r'^\s*\.(?:section|pushsection)\s+["\x27]?\.note', line)
        if note:
            if not marker.fullmatch(line.rstrip('\r\n')):
                raise ValueError('Only an empty .note.GNU-stack marker is allowed')
            in_note = True
            continue
        if in_note:
            if switch.match(line):
                in_note = False
            elif not line.strip() or line.lstrip().startswith('#'):
                continue
            else:
                raise ValueError('Nonempty .note.GNU-stack is not allowed')
        result.append(line)
    return ''.join(result)
