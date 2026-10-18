#!/usr/bin/env python3
"""Verify source/PiPL/guide identity without requiring Adobe headers."""
import plistlib
import re
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
for source in ['RB_ASCII-mac/src/RB_ASCII.mm', 'RB_ASCII-windows/src/RB_ASCIIWin.cpp']:
    text = (ROOT / source).read_text(encoding='utf-8')
    assert 'PF_VERSION(0, 4, 4, PF_Stage_BETA, 2)' in text, source
    assert 'PARAM_COUNT = 40' in text and 'P_TURBULENCE_SCALE = 33' in text, source
    assert '0x288' in text and '0x31574354u' in text, source
r = (ROOT / 'RB_ASCII-mac/pipl/RB_ASCIIPiPL.r').read_text(encoding='utf-8')
assert '0x00022402' in r and '0x02000004' in r
assert 'Name { "RB_ASCII Native" }' in r and 'Category { "RB_ASCII" }' in r
assert 'AE_Effect_Match_Name { "CW CharWeave Native" }' in r  # legacy project identity
info = plistlib.loads((ROOT / 'RB_ASCII-mac/Info.plist').read_bytes())
assert info['CFBundleVersion'] == '40402' and info['CFBundleShortVersionString'] == '0.4.4'
assert info['CFBundleExecutable'] == 'RB_ASCII' and info['CFBundleName'] == 'RB_ASCII Native'
pipl = (ROOT / 'RB_ASCII-windows/pipl/pipl.bin').read_bytes()
i, props = 10, {}
for _ in range(struct.unpack_from('<I', pipl, 6)[0]):
    vendor, key, ident, size = struct.unpack_from('<4s4sII', pipl, i)
    props[key] = pipl[i+16:i+16+size]
    i += 16 + ((size+3)//4)*4
assert i == len(pipl)
assert props[b'eman'][1:1+props[b'eman'][0]] == b'RB_ASCII Native'
assert props[b'gtac'][1:1+props[b'gtac'][0]] == b'RB_ASCII'
assert props[b'ANMe'] == b'\x13CW CharWeave Native'  # legacy project identity
assert struct.unpack('<I', props[b'REVe'])[0] == 0x22402
assert struct.unpack('<I', props[b'OLGe'])[0] == 0x02000004
# Markdown relative links must resolve from the actual source tree.
for doc in ROOT.rglob('*.md'):
    if '.git' in doc.relative_to(ROOT).parts:
        continue
    for target in re.findall(r'\]\(([^)]+)\)', doc.read_text(encoding='utf-8')):
        if '://' not in target and not target.startswith('#'):
            assert (doc.parent / target.split('#')[0]).exists(), (doc, target)
print('PASS version 0.4.4 beta 2 / PF & PiPL 0x00022402 / bundle 40402 / IDs & TCW1 / guide links')
