# Container Comparsions

Minimal Dockerized "hello world" in Rust, C++, Haskell, Node.js, Java, and Python — compiled languages build `FROM scratch` with zero runtime dependencies, while the interpreted languages use AOT/bundling tools on minimal base images.

## Quick start

```sh
chmod +x run.sh && ./run.sh
```

The script displays a live-updating comparison table that fills in as builds and benchmarks complete:

```
IMAGE         DOCKER SIZE     DOCKER AVG   APPLE SIZE      APPLE AVG
──────────── ──────────── ────────────── ──────────── ──────────────
rust                395kB      151.71 ms       212 KB      681.20 ms
cpp                  832B      152.56 ms         2 KB      692.51 ms
haskell            1.06MB      147.88 ms       375 KB      741.10 ms
node                118MB      151.13 ms      47.4 MB      677.86 ms
java               47.3MB      159.14 ms      13.5 MB      675.59 ms
python             27.2MB      177.87 ms      12.1 MB      739.03 ms

  Done.
```

## Options

`run.sh` supports the following environment variables:

| Variable | Effect |
|----------|--------|
| `SKIP_APPLE=1` | Skip Apple Container builds entirely (Docker only) |
| `N_RUNS=25` | Number of benchmark runs per image (default: `10`) |

### Examples

```sh
# Docker + Apple Container (default)
./run.sh

# Docker only
SKIP_APPLE=1 ./run.sh

# Docker only, 50 benchmark runs
SKIP_APPLE=1 N_RUNS=50 ./run.sh
```
