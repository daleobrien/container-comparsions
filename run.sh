#!/bin/sh
set -e

N_RUNS=${N_RUNS:-10}
SKIP_APPLE=${SKIP_APPLE:-}
SKIP_COLIMA=${SKIP_COLIMA:-}

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
APPLE_WAS_RUNNING=false
if $APPLE_AVAILABLE; then
    if container system status 2>&1 | grep -qv 'is not running'; then
        APPLE_WAS_RUNNING=true
    else
        echo "=== Starting apple container service ==="
        container system start
    fi
fi

# --- Detect / manage Colima ---
COLIMA_AVAILABLE=false
COLIMA_WAS_RUNNING=false
if [ -z "$SKIP_COLIMA" ] && command -v colima > /dev/null 2>&1; then
    if colima status 2>&1 | grep -q 'Running'; then
        if colima status 2>&1 | grep -q 'runtime: containerd'; then
            COLIMA_WAS_RUNNING=true
            COLIMA_AVAILABLE=true
        else
            echo "=== Colima is running but NOT using containerd runtime ==="
            echo "=== Run: colima delete && colima start --runtime containerd ==="
            echo "=== Skipping Colima for this run ==="
        fi
    else
        echo "=== Starting Colima (containerd) ==="
        colima start --runtime containerd
        COLIMA_AVAILABLE=true
    fi
else
    if [ -n "$SKIP_COLIMA" ]; then
        echo "=== Colima skipped (SKIP_COLIMA is set) ==="
    fi
fi

# --- Run builds and benchmarks (Python handles the live table) ---
export N_RUNS SKIP_APPLE
if $COLIMA_AVAILABLE; then
    :  # Colima runs by default; nothing to export
else
    export SKIP_COLIMA=1
fi
python3 support/run.py

# --- Stop Colima only if we started it ---
if ! $COLIMA_WAS_RUNNING && $COLIMA_AVAILABLE; then
    echo ""
    echo "=== Stopping Colima ==="
    colima stop
fi

# --- Stop apple container only if it wasn't already running ---
if ! $APPLE_WAS_RUNNING && $APPLE_AVAILABLE; then
    echo ""
    echo "=== Stopping apple container service ==="
    container system stop
fi
