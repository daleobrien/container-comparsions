#!/bin/sh
set -e

N_RUNS=10

# --- Detect apple container CLI ---
APPLE_AVAILABLE=false
if command -v container > /dev/null 2>&1; then
    APPLE_AVAILABLE=true
fi

# --- Start apple container service if needed ---
WAS_RUNNING=false
if $APPLE_AVAILABLE; then
    if container system status 2>&1 | grep -qv 'is not running'; then
        WAS_RUNNING=true
    else
        echo "=== Starting apple container service ==="
        container system start
    fi
fi

# --- Build with Docker ---
echo "=== Building with Docker ==="
docker build --platform linux/arm64 -q -t hello-rust rust/ > /dev/null 2>&1
docker build --platform linux/arm64 -q -t hello-cpp cpp/ > /dev/null 2>&1

# --- Build with Apple Container ---
if $APPLE_AVAILABLE; then
    echo "=== Building with Apple Container ==="
    container build --arch arm64 --tag hello-rust-apple --file rust/Dockerfile rust/ > /dev/null 2>&1
    container build --arch arm64 --tag hello-cpp-apple --file cpp/Dockerfile cpp/ > /dev/null 2>&1
fi

# --- Get image sizes ---
size_rust_docker=$(docker images --format "{{.Size}}" hello-rust)
size_cpp_docker=$(docker images --format "{{.Size}}" hello-cpp)

if $APPLE_AVAILABLE; then
    size_rust_apple=$(container image list -v | awk -v name="hello-rust-apple" -v tag="latest" '$1==name && $2==tag {print $(NF-3), $(NF-2)}')
    size_cpp_apple=$(container image list -v  | awk -v name="hello-cpp-apple"  -v tag="latest" '$1==name && $2==tag {print $(NF-3), $(NF-2)}')
fi

# --- Build benchmark spec list (newline-separated, pipe-delimited fields) ---
SPECS=$(printf '%s|%s|%s|%s\n' \
    "hello-rust" "docker" "hello-rust" "$size_rust_docker" \
    "hello-cpp"  "docker" "hello-cpp"  "$size_cpp_docker")
if $APPLE_AVAILABLE; then
    SPECS="$SPECS
$(printf '%s|%s|%s|%s\n' \
    "hello-rust-apple:latest" "container" "hello-rust" "$size_rust_apple" \
    "hello-cpp-apple:latest"  "container" "hello-cpp"  "$size_cpp_apple")"
fi

# --- Unified benchmark + comparison table ---
echo ""
echo "=== Benchmark (${N_RUNS} runs each) ==="

export N_RUNS SPECS
avgs=$(python3 << 'PYEOF'
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

def update_row(label, rt, size, i, avg):
    global rows_drawn
    row_idx = [b[2] for b in benchmarks].index(image)
    up = rows_drawn - row_idx
    rt_label = 'apple' if rt == 'container' else rt
    if i >= n:
        prog = '[ done ]'
    else:
        prog = f'[{i:>4}/{n:<4}]'
    # Move up to the target row, clear line, write content, move back down,
    # then \r to ensure cursor returns to column 0 for the next add_row.
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
        update_row(label, runtime, size, i, total / i)

    results.append(total / n)

sys.stderr.write('\n')

for avg in results:
    print(avg)
PYEOF
)

# Parse averages back into shell variables
set -- $avgs
avg_rust_docker=$1
avg_cpp_docker=$2
if $APPLE_AVAILABLE; then
    avg_rust_apple=$3
    avg_cpp_apple=$4
fi

# --- Stop apple container only if it wasn't already running ---
if ! $WAS_RUNNING && $APPLE_AVAILABLE; then
    echo ""
    echo "=== Stopping apple container service ==="
    container system stop
fi
