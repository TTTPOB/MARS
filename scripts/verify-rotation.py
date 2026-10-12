#!/usr/bin/env python3
"""Exercise the real CLI and assert sequence-preserving circular rotations."""
import random
import subprocess
import sys
from pathlib import Path


def fasta(path):
    records = {}
    name = None
    for line in path.read_text().splitlines():
        if line.startswith('>'):
            name = line[1:]
            records[name] = ''
        elif line.strip():
            records[name] += line.strip().upper()
    return records


def run(binary, source, target):
    result = subprocess.run(
        [str(binary), '-a', 'DNA', '-m', '0', '-i', str(source), '-o', str(target),
         '-q', '5', '-l', '20', '-P', '1'],
        check=True, capture_output=True, text=True, timeout=120,
    )
    target.with_suffix('.log').write_text(result.stdout + result.stderr)
    before, after = fasta(source), fasta(target)
    assert before.keys() == after.keys(), 'FASTA record identifiers changed'
    changed = 0
    for name, sequence in before.items():
        rotated = after[name]
        assert len(sequence) == len(rotated), f'{name}: sequence length changed'
        assert rotated in sequence + sequence, f'{name}: not a circular rotation'
        changed += sequence != rotated
    assert changed > 0, 'No actual sequence was rotated'
    print(f'{source.name}: {len(before)} records, {changed} changed, all circular rotations')
    return after


binary = Path(sys.argv[1]).resolve()
root = Path(__file__).resolve().parents[1]
work = root / '.build' / 'smoke'
work.mkdir(parents=True, exist_ok=True)
rng = random.Random(20261012)
sequence = ''.join(rng.choice('ACGT') for _ in range(240))
source = work / 'circular-input.fasta'
source.write_text(''.join(
    f'>rotation-{shift}\n{sequence[shift:] + sequence[:shift]}\n'
    for shift in (0, 37, 91)
))
after = run(binary, source, work / 'circular-output.fasta')
assert len(set(after.values())) == 1, 'Identical circular sequences did not align to one origin'
run(binary, root / 'data' / '10.gappy.fasta', work / 'official-output.fasta')
