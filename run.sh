#!/bin/sh
set -e

N_RUNS=${N_RUNS:-10}
SKIP_APPLE=${SKIP_APPLE:-}
VERBOSE=${VERBOSE:-}

# --- Detect apple container CLI ---
APPLE_AVAILABLE=false
if command -v container > /dev/null 2>&1; then
    if [ -z "$SKIP_APPLE" ]; then
        APPLE_AVAILABLE=true
    else
        echo "=== Apple Container skipped (SKIP_APPLE is set) ==="
    fi
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

# --- Run builds and benchmarks (Python handles the live table) ---
export N_RUNS SKIP_APPLE
python3 support/run.py

# --- Stop apple container only if it wasn't already running ---
if ! $WAS_RUNNING && $APPLE_AVAILABLE; then
    echo ""
    echo "=== Stopping apple container service ==="
    container system stop
fi
