#!/usr/bin/env python3
"""
Container comparison runner with live-updating comparison table.

Each row is an image. Columns are SIZE and AVG for each runtime
(docker and apple container). Cells fill in as builds and benchmarks
complete. A status line at the bottom shows the current operation.
"""

import os
import subprocess
import sys
import time

# ── Configuration from environment ────────────────────────────────────────

N_RUNS = int(os.environ.get('N_RUNS', '10'))
SKIP_APPLE = os.environ.get('SKIP_APPLE', '') != ''

IMAGES = ['rust', 'cpp', 'haskell', 'node', 'java', 'python']

# ── ANSI terminal codes ───────────────────────────────────────────────────

HOME = '\033[H'
CLEAR_SCREEN = '\033[2J'
CLEAR_TO_END = '\033[J'
HIDE_CURSOR = '\033[?25l'
SHOW_CURSOR = '\033[?25h'

# ── Table state ───────────────────────────────────────────────────────────

PENDING = '\u2026'  # ellipsis for unfilled cells

data = {
    img: {
        'docker':    {'size': PENDING, 'avg': PENDING},
        'container': {'size': PENDING, 'avg': PENDING},
    }
    for img in IMAGES
}

status = ''


# ── Drawing ────────────────────────────────────────────────────────────────

def draw():
    """Redraw the full screen: table header, data rows, and status line."""
    lines = [f'{HOME}{CLEAR_SCREEN}']

    # Table header
    if SKIP_APPLE:
        lines.append(f'{"IMAGE":<12} {"DOCKER SIZE":>12} {"DOCKER AVG":>14}')
    else:
        header = f'{"IMAGE":<12} {"DOCKER SIZE":>12} {"DOCKER AVG":>14}'
        header += f' {"APPLE SIZE":>12} {"APPLE AVG":>14}'
        lines.append(header)

    # Separator
    if SKIP_APPLE:
        lines.append(f'{"─" * 12} {"─" * 12} {"─" * 14}')
    else:
        lines.append(f'{"─" * 12} {"─" * 12} {"─" * 14} {"─" * 12} {"─" * 14}')

    # Data rows
    for img in IMAGES:
        ds = data[img]['docker']['size']
        da = data[img]['docker']['avg']
        if SKIP_APPLE:
            lines.append(f'{img:<12} {ds:>12} {da:>14}')
        else:
            cs = data[img]['container']['size']
            ca = data[img]['container']['avg']
            lines.append(f'{img:<12} {ds:>12} {da:>14} {cs:>12} {ca:>14}')

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

def build_docker(label):
    """Build docker image, return size string."""
    image = f'hello-{label}'
    set_status(f'Building {label} (docker)...')
    subprocess.run(
        ['docker', 'build', '--platform', 'linux/arm64', '-t', image, f'{label}/'],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True,
    )
    result = subprocess.run(
        ['docker', 'images', '--format', '{{.Size}}', image],
        capture_output=True, text=True, check=True,
    )
    return result.stdout.strip()


def build_apple(label):
    """Build apple container image, return size string."""
    image = f'hello-{label}-apple'
    set_status(f'Building {label} (apple)...')
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
    if runtime == 'docker':
        image = f'hello-{label}'
        cmd = ['docker', 'run', '--rm', image]
    else:
        image = f'hello-{label}-apple:latest'
        cmd = ['container', 'run', image]

    start = time.time()
    subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return (time.time() - start) * 1000


def benchmark(label, runtime):
    """Run N_RUNS benchmarks, updating the avg cell after each run."""
    total = 0.0
    rt_label = 'apple' if runtime == 'container' else runtime
    for i in range(1, N_RUNS + 1):
        total += _run_once(label, runtime)
        avg = total / i
        data[label][runtime]['avg'] = f'{avg:.2f} ms'
        set_status(f'Benchmarking {label} ({rt_label})  run {i}/{N_RUNS}')


# ── Main ───────────────────────────────────────────────────────────────────

def main():
    sys.stderr.write(HIDE_CURSOR)
    try:
        # ── Phase 1: Build ──
        for img in IMAGES:
            data[img]['docker']['size'] = build_docker(img)

        if not SKIP_APPLE:
            for img in IMAGES:
                data[img]['container']['size'] = build_apple(img)

        # ── Phase 2: Benchmark ──
        for img in IMAGES:
            benchmark(img, 'docker')

        if not SKIP_APPLE:
            for img in IMAGES:
                benchmark(img, 'container')

        set_status('Done.')
    except subprocess.CalledProcessError as e:
        set_status(f'ERROR: {e}')
        sys.exit(1)
    finally:
        sys.stderr.write(SHOW_CURSOR)


if __name__ == '__main__':
    main()
