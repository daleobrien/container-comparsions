# Container Comparsions

Minimal Dockerized "hello world" in Rust, C++, Haskell, Node.js, Java, and Python — compiled languages build `FROM scratch` with zero runtime dependencies, while the interpreted languages use AOT/bundling tools on minimal base images.

## Quick start

```sh
chmod +x run.sh && ./run.sh
```

The script displays a live-updating comparison table that fills in as builds and benchmarks complete:

```
IMAGE         DOCKER SIZE     DOCKER AVG   APPLE SIZE      APPLE AVG  COLIMA SIZE     COLIMA AVG
──────────── ──────────── ────────────── ──────────── ────────────── ──────────── ──────────────
rust                615kB      118.26 ms       212 KB      682.73 ms        615kB      119.75 ms
cpp                  12kB      114.72 ms         2 KB      668.64 ms         12kB      112.16 ms
haskell            1.45MB      122.05 ms       375 KB      744.49 ms       1.45MB      112.79 ms
node                166MB      117.81 ms      47.4 MB      674.42 ms        166MB      118.95 ms
java               65.2MB      118.69 ms      13.5 MB      640.98 ms       65.2MB      115.71 ms
python             40.1MB      145.27 ms      12.1 MB      725.36 ms       40.1MB      145.53 ms

  Done.
```

## Options

`run.sh` supports the following environment variables:

| Variable | Effect |
|----------|--------|
| `SKIP_COLIMA=1` | Skip [Colima](https://github.com/abiosoft/colima) (included by default when installed) |
| `SKIP_APPLE=1` | Skip Apple Container builds (Docker only) |
| `N_RUNS=25` | Number of benchmark runs per image (default: `10`) |

### Examples

```sh
# Docker + Apple Container + Colima (default, when Colima is installed)
./run.sh

# Docker + Apple Container only (skip Colima)
SKIP_COLIMA=1 ./run.sh

# Docker + Colima only
SKIP_APPLE=1 ./run.sh

# Docker only
SKIP_APPLE=1 SKIP_COLIMA=1 ./run.sh

# Docker only, 50 benchmark runs
SKIP_APPLE=1 SKIP_COLIMA=1 N_RUNS=50 ./run.sh
```
