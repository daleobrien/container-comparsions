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
rust                395kB      140.67 ms       212 KB      708.20 ms      401.4kB      491.41 ms
cpp                  832B      134.72 ms         2 KB      663.99 ms      8.192kB      451.82 ms
haskell            1.06MB      137.05 ms       375 KB      760.13 ms      1.069MB      451.95 ms
node                118MB      138.99 ms      47.4 MB      678.13 ms      118.7MB      442.01 ms
java               47.3MB      137.50 ms      13.5 MB      629.79 ms      51.68MB      448.47 ms
python             27.2MB      167.92 ms      12.1 MB      717.05 ms      28.01MB      485.89 ms

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
