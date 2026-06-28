#!/bin/sh
set -e

N_RUNS=10
VERBOSE=${VERBOSE:-}

quiet() {
    if [ -n "$VERBOSE" ]; then
        "$@"
    else
        "$@" > /dev/null 2>&1
    fi
}

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
quiet docker build --platform linux/arm64 -t hello-rust rust/
quiet docker build --platform linux/arm64 -t hello-cpp cpp/
quiet docker build --platform linux/arm64 -t hello-node node/
quiet docker build --platform linux/arm64 -t hello-java java/
quiet docker build --platform linux/arm64 -t hello-python python/

# --- Build with Apple Container ---
if $APPLE_AVAILABLE; then
    echo "=== Building with Apple Container ==="
    quiet container build --arch arm64 --tag hello-rust-apple --file rust/Dockerfile rust/
    quiet container build --arch arm64 --tag hello-cpp-apple --file cpp/Dockerfile cpp/
    quiet container build --arch arm64 --tag hello-node-apple --file node/Dockerfile node/
    quiet container build --arch arm64 --tag hello-java-apple --file java/Dockerfile java/
    quiet container build --arch arm64 --tag hello-python-apple --file python/Dockerfile python/
fi

# --- Get image sizes ---
size_rust_docker=$(docker images --format "{{.Size}}" hello-rust)
size_cpp_docker=$(docker images --format "{{.Size}}" hello-cpp)
size_node_docker=$(docker images --format "{{.Size}}" hello-node)
size_java_docker=$(docker images --format "{{.Size}}" hello-java)
size_python_docker=$(docker images --format "{{.Size}}" hello-python)

if $APPLE_AVAILABLE; then
    size_rust_apple=$(container image list -v | awk -v name="hello-rust-apple" -v tag="latest" '$1==name && $2==tag {print $(NF-3), $(NF-2)}')
    size_cpp_apple=$(container image list -v  | awk -v name="hello-cpp-apple"  -v tag="latest" '$1==name && $2==tag {print $(NF-3), $(NF-2)}')
    size_node_apple=$(container image list -v | awk -v name="hello-node-apple" -v tag="latest" '$1==name && $2==tag {print $(NF-3), $(NF-2)}')
    size_java_apple=$(container image list -v | awk -v name="hello-java-apple" -v tag="latest" '$1==name && $2==tag {print $(NF-3), $(NF-2)}')
    size_python_apple=$(container image list -v | awk -v name="hello-python-apple" -v tag="latest" '$1==name && $2==tag {print $(NF-3), $(NF-2)}')
fi

# --- Build benchmark spec list (newline-separated, pipe-delimited fields) ---
SPECS=$(printf '%s|%s|%s|%s\n' \
    "hello-rust" "docker" "hello-rust" "$size_rust_docker" \
    "hello-cpp"  "docker" "hello-cpp"  "$size_cpp_docker" \
    "hello-node" "docker" "hello-node" "$size_node_docker" \
    "hello-java" "docker" "hello-java" "$size_java_docker" \
    "hello-python" "docker" "hello-python" "$size_python_docker")
if $APPLE_AVAILABLE; then
    SPECS="$SPECS
$(printf '%s|%s|%s|%s\n' \
    "hello-rust-apple:latest" "container" "hello-rust" "$size_rust_apple" \
    "hello-cpp-apple:latest"  "container" "hello-cpp"  "$size_cpp_apple" \
    "hello-node-apple:latest" "container" "hello-node" "$size_node_apple" \
    "hello-java-apple:latest" "container" "hello-java" "$size_java_apple" \
    "hello-python-apple:latest" "container" "hello-python" "$size_python_apple")"
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
avg_python_docker=$5
if $APPLE_AVAILABLE; then
    avg_rust_apple=$6
    avg_cpp_apple=$7
    avg_node_apple=$8
    avg_java_apple=$9
    avg_python_apple=${10}
fi

# --- Stop apple container only if it wasn't already running ---
if ! $WAS_RUNNING && $APPLE_AVAILABLE; then
    echo ""
    echo "=== Stopping apple container service ==="
    container system stop
fi
