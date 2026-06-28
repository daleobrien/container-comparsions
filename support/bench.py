#!/usr/bin/env python3
"""Benchmark runner with live-updating table.

Reads SPECS (pipe-delimited lines: image|runtime|label|size) and N_RUNS from
the environment.  Writes progress to stderr and one average per benchmark
to stdout.
"""

import os, subprocess, time, sys

specs_text = os.environ['SPECS'].strip()
n = int(os.environ['N_RUNS'])

benchmarks = []
for line in specs_text.split('\n'):
    line = line.strip()
    if not line:
        continue
    image, runtime, label, size = line.split('|')
    benchmarks.append((label, runtime, image, size))

rows_drawn = 0

def draw_header():
    sys.stderr.write(f'{"IMAGE":<18} {"RUNTIME":<10} {"SIZE":>10} {"PROGRESS":>12} {"AVG":>12}\n')
    sys.stderr.write(f'{"─" * 18} {"─" * 10} {"─" * 10} {"─" * 12} {"─" * 12}\n')
    sys.stderr.flush()

def add_row(label, rt, size):
    global rows_drawn
    rt_label = 'apple' if rt == 'container' else rt
    sys.stderr.write(f'{label:<18} {rt_label:<10} {size:>10} {"":>12} {"":>12}\n')
    rows_drawn += 1
    sys.stderr.flush()

def update_row(label, rt, size, i, avg, image):
    global rows_drawn
    row_idx = [b[2] for b in benchmarks].index(image)
    up = rows_drawn - row_idx
    rt_label = 'apple' if rt == 'container' else rt
    if i >= n:
        prog = '[ done ]'
    else:
        prog = f'[{i:>4}/{n:<4}]'
    sys.stderr.write(
        f'\033[{up}A\r\033[K'
        f'{label:<18} {rt_label:<10} {size:>10} {prog:>12} {avg:>8.2f} ms'
        f'\033[{up}B\r'
    )
    sys.stderr.flush()

# Draw header once
draw_header()

results = []
for label, runtime, image, size in benchmarks:
    # Add a new row for this benchmark
    add_row(label, runtime, size)

    if runtime == 'docker':
        cmd = ['docker', 'run', '--rm', image]
    else:
        cmd = ['container', 'run', image]

    total = 0.0
    for i in range(1, n + 1):
        start = time.time()
        subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        total += (time.time() - start) * 1000
        update_row(label, runtime, size, i, total / i, image)

    results.append(total / n)

sys.stderr.write('\n')

for avg in results:
    print(avg)
