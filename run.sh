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
docker build --platform linux/arm64 -q -t hello-node node/ > /dev/null 2>&1
docker build --platform linux/arm64 -q -t hello-java java/ > /dev/null 2>&1

# --- Build with Apple Container ---
if $APPLE_AVAILABLE; then
    echo "=== Building with Apple Container ==="
    container build --arch arm64 --tag hello-rust-apple --file rust/Dockerfile rust/ > /dev/null 2>&1
    container build --arch arm64 --tag hello-cpp-apple --file cpp/Dockerfile cpp/ > /dev/null 2>&1
    container build --arch arm64 --tag hello-node-apple --file node/Dockerfile node/ > /dev/null 2>&1
    container build --arch arm64 --tag hello-java-apple --file java/Dockerfile java/ > /dev/null 2>&1
fi

# --- Get image sizes ---
size_rust_docker=$(docker images --format "{{.Size}}" hello-rust)
size_cpp_docker=$(docker images --format "{{.Size}}" hello-cpp)
size_node_docker=$(docker images --format "{{.Size}}" hello-node)
size_java_docker=$(docker images --format "{{.Size}}" hello-java)

if $APPLE_AVAILABLE; then
    size_rust_apple=$(container image list -v | awk -v name="hello-rust-apple" -v tag="latest" '$1==name && $2==tag {print $(NF-3), $(NF-2)}')
    size_cpp_apple=$(container image list -v  | awk -v name="hello-cpp-apple"  -v tag="latest" '$1==name && $2==tag {print $(NF-3), $(NF-2)}')
    size_node_apple=$(container image list -v | awk -v name="hello-node-apple" -v tag="latest" '$1==name && $2==tag {print $(NF-3), $(NF-2)}')
    size_java_apple=$(container image list -v | awk -v name="hello-java-apple" -v tag="latest" '$1==name && $2==tag {print $(NF-3), $(NF-2)}')
fi

# --- Build benchmark spec list (newline-separated, pipe-delimited fields) ---
SPECS=$(printf '%s|%s|%s|%s\n' \
    "hello-rust" "docker" "hello-rust" "$size_rust_docker" \
    "hello-cpp"  "docker" "hello-cpp"  "$size_cpp_docker" \
    "hello-node" "docker" "hello-node" "$size_node_docker" \
    "hello-java" "docker" "hello-java" "$size_java_docker")
if $APPLE_AVAILABLE; then
    SPECS="$SPECS
$(printf '%s|%s|%s|%s\n' \
    "hello-rust-apple:latest" "container" "hello-rust" "$size_rust_apple" \
    "hello-cpp-apple:latest"  "container" "hello-cpp"  "$size_cpp_apple" \
    "hello-node-apple:latest" "container" "hello-node" "$size_node_apple" \
    "hello-java-apple:latest" "container" "hello-java" "$size_java_apple")"
fi

# --- Unified benchmark + comparison table ---
echo ""
echo "=== Benchmark (${N_RUNS} runs each) ==="

export N_RUNS SPECS
avgs=$(python3 support/bench.py)

# Parse averages back into shell variables
set -- $avgs
avg_rust_docker=$1
avg_cpp_docker=$2
avg_node_docker=$3
avg_java_docker=$4
if $APPLE_AVAILABLE; then
    avg_rust_apple=$5
    avg_cpp_apple=$6
    avg_node_apple=$7
    avg_java_apple=$8
fi

# --- Stop apple container only if it wasn't already running ---
if ! $WAS_RUNNING && $APPLE_AVAILABLE; then
    echo ""
    echo "=== Stopping apple container service ==="
    container system stop
fi
