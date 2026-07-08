#!/usr/bin/env python3
"""
Container comparison runner with live-updating comparison table.

Each row is an image. Columns are SIZE and AVG for each active runtime
(docker, apple container, and optionally colima). Cells fill in as
builds and benchmarks complete. A status line shows the current operation.
"""

import os
import subprocess
import sys
import time

# ── Configuration from environment ────────────────────────────────────────

N_RUNS = int(os.environ.get('N_RUNS', '10'))
SKIP_APPLE = os.environ.get('SKIP_APPLE', '') != ''
SKIP_COLIMA = os.environ.get('SKIP_COLIMA', '') != ''
COLIMA_SOCKET = os.environ.get('COLIMA_SOCKET',
                                f'unix://{os.environ["HOME"]}/.colima/default/docker.sock')

IMAGES = ['rust', 'cpp', 'haskell', 'node', 'java', 'python']

# ── Active runtimes (order determines table column order) ─────────────────

RUNTIMES = ['docker']
if not SKIP_APPLE:
    RUNTIMES.append('apple')
if not SKIP_COLIMA:
    RUNTIMES.append('colima')

# Human-readable column header for each runtime
RUNTIME_HEADERS = {
    'docker':  'DOCKER',
    'apple':   'APPLE',
    'colima':  'COLIMA',
}

# ── ANSI terminal codes ───────────────────────────────────────────────────

HOME = '\033[H'
CLEAR_SCREEN = '\033[2J'
CLEAR_TO_END = '\033[J'
HIDE_CURSOR = '\033[?25l'
SHOW_CURSOR = '\033[?25h'

# ── Table state ───────────────────────────────────────────────────────────

PENDING = '\u2026'  # ellipsis for unfilled cells

data = {
    img: {rt: {'size': PENDING, 'avg': PENDING} for rt in RUNTIMES}
    for img in IMAGES
}

status = ''

COL_W = {'IMAGE': 12, 'SIZE': 12, 'AVG': 14}


# ── Drawing ────────────────────────────────────────────────────────────────

def draw():
    """Redraw the full screen: table header, data rows, and status line."""
    lines = [f'{HOME}{CLEAR_SCREEN}']

    # Header
    header = f'{"IMAGE":<{COL_W["IMAGE"]}}'
    for rt in RUNTIMES:
        header += f' {RUNTIME_HEADERS[rt] + " SIZE":>{COL_W["SIZE"]}}'
        header += f' {RUNTIME_HEADERS[rt] + " AVG":>{COL_W["AVG"]}}'
    lines.append(header)

    # Separator
    sep = f'{"─" * COL_W["IMAGE"]}'
    for _ in RUNTIMES:
        sep += f' {"─" * COL_W["SIZE"]} {"─" * COL_W["AVG"]}'
    lines.append(sep)

    # Data rows
    for img in IMAGES:
        row = f'{img:<{COL_W["IMAGE"]}}'
        for rt in RUNTIMES:
            row += f' {data[img][rt]["size"]:>{COL_W["SIZE"]}}'
            row += f' {data[img][rt]["avg"]:>{COL_W["AVG"]}}'
        lines.append(row)

    # Status line
    lines.append('')
    lines.append(f'  {status}{CLEAR_TO_END}')

    sys.stderr.write('\n'.join(lines))
    sys.stderr.flush()


def set_status(msg):
    """Update status line and repaint."""
    global status
    status = msg
    draw()


# ── Build helpers ──────────────────────────────────────────────────────────

def _docker_cmd(runtime):
    """Return the docker CLI prefix for the given runtime."""
    if runtime == 'colima':
        return ['docker', '-H', COLIMA_SOCKET]
    return ['docker']


def build(label, runtime):
    """Build image for the given runtime, return size string."""
    rt_label = RUNTIME_HEADERS[runtime]
    set_status(f'Building {label} ({rt_label.lower()})...')

    if runtime in ('docker', 'colima'):
        image = f'hello-{label}'
        cmd = _docker_cmd(runtime)
        subprocess.run(
            cmd + ['build', '--platform', 'linux/arm64', '-t', image, f'{label}/'],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True,
        )
        result = subprocess.run(
            cmd + ['images', '--format', '{{.Size}}', image],
            capture_output=True, text=True, check=True,
        )
        return result.stdout.strip()

    else:  # apple
        image = f'hello-{label}-apple'
        subprocess.run(
            ['container', 'build', '--arch', 'arm64', '--tag', image,
             '--file', f'{label}/Dockerfile', f'{label}/'],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True,
        )
        result = subprocess.run(
            ['container', 'image', 'list', '-v'],
            capture_output=True, text=True, check=True,
        )
        for line in result.stdout.strip().split('\n'):
            parts = line.split()
            if len(parts) >= 5 and parts[0] == image and parts[1] == 'latest':
                return f'{parts[-4]} {parts[-3]}'
        return '---'


# ── Benchmark helpers ──────────────────────────────────────────────────────

def _run_once(label, runtime):
    """Execute the container once, return elapsed milliseconds."""
    if runtime in ('docker', 'colima'):
        image = f'hello-{label}'
        cmd = _docker_cmd(runtime) + ['run', '--rm', image]
    else:  # apple
        image = f'hello-{label}-apple:latest'
        cmd = ['container', 'run', image]

    start = time.time()
    subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return (time.time() - start) * 1000


def benchmark(label, runtime):
    """Run N_RUNS benchmarks, updating the avg cell after each run."""
    total = 0.0
    rt_label = RUNTIME_HEADERS[runtime].lower()
    for i in range(1, N_RUNS + 1):
        total += _run_once(label, runtime)
        avg = total / i
        data[label][runtime]['avg'] = f'{avg:.2f} ms'
        set_status(f'Benchmarking {label} ({rt_label})  run {i}/{N_RUNS}')


# ── Main ───────────────────────────────────────────────────────────────────

def main():
    sys.stderr.write(HIDE_CURSOR)
    try:
        # Phase 1: Build
        for rt in RUNTIMES:
            for img in IMAGES:
                data[img][rt]['size'] = build(img, rt)

        # Phase 2: Benchmark
        for rt in RUNTIMES:
            for img in IMAGES:
                benchmark(img, rt)

        set_status('Done.')
    except subprocess.CalledProcessError as e:
        set_status(f'ERROR: {e}')
        sys.exit(1)
    finally:
        sys.stderr.write(SHOW_CURSOR)


if __name__ == '__main__':
    main()
